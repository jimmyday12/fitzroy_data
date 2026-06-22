# Shared helpers for the fitzroy_data contract tests.
#
# DESIGN — characterization / golden-master.
# On the FIRST run, each test captures the current reality into
# tests/testthat/_fixtures/ and skips. On EVERY later run it compares against
# that captured truth. This makes today's pipeline output the contract, so any
# drift the cleanup introduces is caught. Capture the fixtures BEFORE you start
# changing anything, commit them, and from then on the suite is your regression
# gate.

library(testthat)

# The two most recent seasons are re-scraped every week, so their values
# legitimately change between runs. Exact-value characterization must therefore
# run ONLY on the frozen historical slice — everything before this cutoff should
# never change. (Matches `rescrape_start_season` logic in the weekly scripts.)
STABLE_BEFORE <- as.numeric(format(Sys.Date(), "%Y")) - 1L

data_path <- function(...) here::here("data-raw", ...)

# Load a single-object .rda without knowing the object's name.
load_rda <- function(path) {
  e <- new.env(parent = emptyenv())
  load(path, envir = e)
  get(ls(e)[1L], envir = e)
}

# The frozen historical portion that should be byte-stable between runs.
stable_slice <- function(df) {
  df <- dplyr::ungroup(df)
  df[df$Season < STABLE_BEFORE, , drop = FALSE]
}

# Capture-on-first-run, compare-after. Uses testthat 3e's waldo backend, which
# is strict about types (int vs double) — exactly what we want for a contract.
expect_golden <- function(value, name) {
  path <- test_path("_fixtures", paste0(name, ".rds"))
  if (!file.exists(path)) {
    dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
    saveRDS(value, path)
    skip(sprintf("Captured golden fixture '%s' — re-run to test against it.", name))
  }
  expect_equal(value, readRDS(path))
}
