# Weekly Script for Footywire data
# This script runs weekly on a CRON Job on Github. The data is sometimes used in the
# fitzRoy package to cache data rather than having to scrape the websites regularly

# Setup --------------------------------------------
# Libraries
library(here)
library(tidyverse)
library(fitzRoy)
library(cli)
library(fst)

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

## Save rescrape
cli::cli_progress_step("Saving rescraped footywire player stats")
save(player_stats,
     file = here::here("data-raw", "player_stats", "player_stats_re_scrape.rda"),
     version = 2
)

## Saving data
# Old data - will remove this soon
cli::cli_progress_step("Saving footywire player stats")
save(player_stats,
     file = here::here("data-raw", "player_stats", "player_stats.rda"),
     version = 2
)


# New data location
save(player_stats,
     file = here::here("data-raw-2", "footywire_player_stats.rda"),
     version = 2
)
