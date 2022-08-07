# Script to get data from afltables
library(fitzRoy)
library(dplyr)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda
end_year <- as.numeric(format(Sys.Date(), "%Y"))
seasons <- 1897:end_year
afldata <- fetch_player_stats_afltables(seasons)

# remove duplicate games if exist
afldata <- distinct(afldata)

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

# Write data using devtools
#devtools::use_data(player_stats, overwrite = TRUE)
write_rds(afldata, here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
save(afldata, file = here::here("data-raw", "afl_tables_playerstats", "afldata.rda"))


x <- readRDS(here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
