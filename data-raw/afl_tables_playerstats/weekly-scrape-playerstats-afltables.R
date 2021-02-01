# Script to get data from afltables
library(fitzRoy)
library(dplyr)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda
afldata <- fetch_player_stats_afltables()

# remove duplicate games if exist
afldata <- distinct(afldata)


# Write data using devtools
#devtools::use_data(player_stats, overwrite = TRUE)
write_rds(afldata, here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
save(afldata, file = here::here("data-raw", "afl_tables_playerstats", "afldata.rda"))
