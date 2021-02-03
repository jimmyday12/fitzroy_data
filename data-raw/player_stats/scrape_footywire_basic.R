# Script to get data from footywire - adapted from Rob's earlier one
library(fitzRoy)
library(fst)
library(dplyr)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda

player_stats <- fetch_player_stats_footywire(season = NULL, round_number = NULL, check_existing = TRUE)

player_stats <- player_stats %>% 
  ungroup() %>% 
  distinct()

#load(here::here("data-raw", "player_stats", "player_stats.rda"))

# Write data using devtools
#devtools::use_data(player_stats, overwrite = TRUE)
save(player_stats, file = here::here("data-raw", "player_stats", "player_stats.rda"), version = 2)
save(player_stats, file = here::here("data-raw", "player_stats", "player_stats_end2020.rda"), version = 2)
fst::write_fst(player_stats, path = here::here("data-raw", "player_stats", "player_stats.fst"))
fst::write_fst(player_stats, path = here::here("data-raw", "player_stats", "player_stats_full.fst"), compress = 100)
