# Weekly Script for Footywire data
# This script runs weekly on a CRON Job on Github. The data is sometimes used in the
# fitzRoy package to cache data rather than having to scrape the websites regularly

# Setup --------------------------------------------
# Libraries
library(here)
library(tidyverse)
library(fitzRoy)
library(cli)
library(arrow)

# footywire.com returns HTTP 406 for requests without a browser-like
# User-Agent, which breaks xml2::read_html() calls inside fitzRoy.
# fitzRoy's read_html_fitzroy() sets HTTPUserAgent itself for the duration of
# every read, so setting HTTPUserAgent here has no effect - the option it
# honours is fitzRoy.user_agent. Set both: the first covers fitzRoy's scrapers,
# the second covers any direct url()/read_html() calls in this script.
fw_user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
options(
  fitzRoy.user_agent = fw_user_agent,
  HTTPUserAgent = fw_user_agent
)

source(here::here("scripts", "helpers", "network.R"))
patch_fitzroy_reader()

# Preflight ----------------------------------------
# As of 2026-07-07 footywire.com answers every GitHub-hosted runner with a
# 503, on all three runner OSes and regardless of User-Agent, while serving
# the same request fine from a normal connection. fitzRoy reads pages through
# xml2, which swallows the status and reports only "cannot open the
# connection" from somewhere inside a purrr::map() - so check first and say
# what actually happened.
fw_probe_url <- "https://www.footywire.com/afl/footy/ft_match_list?year=2010"
fw_status <- http_status(fw_probe_url, user_agent = fw_user_agent)

if (!is.na(fw_status) && fw_status != 200) {
  cli::cli_abort(c(
    "footywire.com returned HTTP {fw_status} for {.url {fw_probe_url}}.",
    "i" = "503 here means the host is refusing this runner's IP, not a bad
           fixture or User-Agent - the scrape cannot run from a
           GitHub-hosted runner.",
    "i" = "Run this job on a self-hosted runner with an unblocked IP."
  ))
}

# Variables
end_year <- as.numeric(format(Sys.Date(), "%Y"))
total_seasons <- 1897:end_year
seasons <- (end_year - 1):end_year
rescrape <- TRUE

# Player stats - footywire -----------------------------------------------------

## Fetch data
cli::cli_progress_step("Getting existing footywire player stats")

player_stats <- fetch_player_stats_footywire(
  season = total_seasons,
  round_number = NULL,
  check_existing = TRUE
)

if (rescrape) {
  cli::cli_progress_step("Rescraping footywire player stats")
  player_stats_existing <- player_stats %>% dplyr::filter(!Season %in% seasons)
  player_stats_re_scrape <- fetch_player_stats_footywire(
    season = seasons,
    round_number = NULL,
    check_existing = FALSE
  )
  
  player_stats <- dplyr::bind_rows(player_stats_existing,player_stats_re_scrape)
}


cli::cli_progress_step("Tidying footywire player stats")
player_stats <- player_stats %>%
  ungroup() %>%
  distinct()

## Saving data
cli::cli_progress_step("Saving footywire player stats")
save(player_stats,
     file = here::here("data-raw", "player_stats", "player_stats.rda"),
     version = 2
)

dir.create(here::here("data"), showWarnings = FALSE)
arrow::write_parquet(player_stats, here::here("data", "footywire_player_stats.parquet"))
