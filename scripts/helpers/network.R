# Shared network resilience for the weekly scrapes.
#
# Both scripts hit live sites from a GitHub runner, and fitzRoy aborts the
# whole run on the first failed page. Single transient responses have sunk
# otherwise-healthy jobs twice: a 429 from raw.githubusercontent while
# fetching the cached ID data (2026-08-18), and a blip at match 31 of a
# 423-match afltables rescrape (2026-08-25). So: a polite gap between page
# requests, and retry with exponential backoff before giving up.

# Gap between individual page requests, in seconds. At ~420 matches per
# rescrape this adds ~2 minutes to a job that otherwise runs in 5-6.
request_gap_seconds <- 0.25

# Attempts per request, including the first.
max_attempts <- 4

#' Run `fn`, retrying with exponential backoff on error
#'
#' @param fn A zero-argument function to call.
#' @param what Human-readable description, used in progress and error messages.
#' @param attempts Total attempts, including the first.
#' @param base_delay Seconds to wait after the first failure; doubles each time.
with_retry <- function(fn, what, attempts = max_attempts, base_delay = 2) {
  for (attempt in seq_len(attempts)) {
    result <- tryCatch(fn(), error = function(e) e)

    if (!inherits(result, "error")) {
      return(result)
    }

    if (attempt == attempts) {
      cli::cli_abort(c(
        "{what} failed after {attempts} attempt{?s}.",
        "x" = conditionMessage(result)
      ))
    }

    delay <- base_delay * 2^(attempt - 1)
    cli::cli_alert_warning(
      "{what} failed (attempt {attempt}/{attempts}): {conditionMessage(result)} Retrying in {delay}s."
    )
    Sys.sleep(delay)
  }
}

#' Make fitzRoy's page reader pace itself and retry
#'
#' fitzRoy funnels essentially every scrape through the internal
#' `read_html_fitzroy()`, so wrapping that one binding covers afltables and
#' footywire alike without touching the package. No-op (with a warning) if a
#' future fitzRoy renames it, so a rename degrades to today's behaviour
#' rather than breaking the scripts.
patch_fitzroy_reader <- function() {
  ns <- asNamespace("fitzRoy")

  if (!exists("read_html_fitzroy", envir = ns, inherits = FALSE)) {
    cli::cli_alert_warning(
      "fitzRoy:::read_html_fitzroy() not found - scraping without retry."
    )
    return(invisible(FALSE))
  }

  original <- get("read_html_fitzroy", envir = ns)

  # Sourcing this file twice must not wrap the wrapper.
  if (isTRUE(attr(original, "fitzroy_data_retry"))) {
    return(invisible(TRUE))
  }

  patched <- function(url) {
    Sys.sleep(request_gap_seconds)
    with_retry(function() original(url), what = paste("Reading", url))
  }
  attr(patched, "fitzroy_data_retry") <- TRUE

  # Reaching into a namespace is a blunt instrument; if a future R or fitzRoy
  # refuses the assignment, carry on unpatched rather than taking the run down
  # with us.
  tryCatch(
    {
      assignInNamespace("read_html_fitzroy", patched, ns = "fitzRoy")
      invisible(TRUE)
    },
    error = function(e) {
      cli::cli_alert_warning(
        "Could not patch fitzRoy:::read_html_fitzroy() ({conditionMessage(e)}) - scraping without retry."
      )
      invisible(FALSE)
    }
  )
}

#' Report the HTTP status behind a URL, or NA if the request never completed
#'
#' xml2 swallows the status and reports only "cannot open the connection",
#' which is what made the footywire outage so hard to read in CI logs.
#'
#' Issues a GET, not a HEAD: footywire answers HEAD with a 500 even where the
#' same URL serves 200 to a GET, so a HEAD-based check reports a failure the
#' scraper itself would never hit.
http_status <- function(url, user_agent = getOption("HTTPUserAgent")) {
  if (!requireNamespace("curl", quietly = TRUE)) {
    return(NA_integer_)
  }

  handle <- curl::new_handle(useragent = user_agent, timeout = 30)
  tryCatch(
    curl::curl_fetch_memory(url, handle = handle)$status_code,
    error = function(e) NA_integer_
  )
}
