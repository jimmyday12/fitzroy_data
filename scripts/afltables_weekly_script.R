# Weekly Script for AFL tables data
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
seasons <- 1897:end_year
rescrape = TRUE

# Player Stats - afltables -----------------------------------------------------

## Fetch data
cli::cli_progress_step("Fetching afltables player stats")
afldata_new <- fetch_player_stats_afltables(1897:end_year, 
                                            rescrape = rescrape, 
                                            rescrape_start_season = (end_year - 1))


## Tidy data
cli::cli_progress_step("Tidying afltables player stats")

# remove duplicate games if exist
afldata <- distinct(afldata_new)

## Save data
cli::cli_progress_step("Saving afltables player stats")

# Write ids file
id <- afldata %>%
  ungroup() %>%
  mutate(
    Player = paste(First.name, Surname),
    Team = Playing.for
  ) %>%
  select(Season, Player, ID, Team) %>%
  distinct()


write_csv(id, here::here("data-raw", "afl_tables_playerstats", "player_ids.csv"))
write_rds(afldata, here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
save(afldata, file = here::here("data-raw", "afl_tables_playerstats", "afldata.rda"))

