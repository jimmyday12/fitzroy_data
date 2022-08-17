#Script to get data from afltables
library(fitzRoy)
library(dplyr)
library(readr)
library(arrow)
library(purrr)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda
end_year <- as.numeric(format(Sys.Date(), "%Y"))
seasons <- 1897:end_year

scrape_and_save <- function(start, end) {
  glue::glue("Getting data from {start} to {end}")
  df <- fetch_player_stats_afltables(start:end, rescrape = TRUE)
  fname <- paste0("rescrape_", start, "_", end, ".parquet")
  write_parquet(df, here::here("data-raw", "afl_tables_playerstats", "re-scrape", fname))
}

starts <- c(1897, seq(from = 1900, to = max(seasons), by = 10))
ends <- c((starts - 1)[-1], max(seasons))

purrr::walk2(starts, ends, scrape_and_save)


fnames <- list.files(path = here::here("data-raw", "afl_tables_playerstats", "re-scrape"), 
                     pattern = "*.parquet")

dat_new <- fnames %>%
  purrr::map_chr(~here::here("data-raw", "afl_tables_playerstats", "re-scrape", .x)) %>%
  purrr::map_dfr(read_parquet)

dat_new <- dat_new %>%
  dplyr::mutate_at(., c("Jumper.No."), as.character)

dat_new <- dat_new %>%
  dplyr::group_by(.data$ID) %>%
  dplyr::mutate(
    First.name = dplyr::first(.data$First.name),
    Surname = dplyr::first(.data$Surname)
  )

# fix for finals names being incorrect
dat_new$Round[dat$Round == "Grand Final"] <- "GF"
dat_new$Round[dat$Round == "Elimination Final"] <- "EF"
dat_new$Round[dat$Round == "Preliminary Final"] <- "PF"
dat_new$Round[dat$Round == "Qualifying Final"] <- "QF"
dat_new$Round[dat$Round == "Semi Final"] <- "SF"

# fix for trailing spaces in venues, causing duplicated venue names
dat_new <- dat_new %>%
  dplyr::mutate(Venue = stringr::str_squish(.data$Venue))

# remove duplicate games if exist
afldata <- distinct(dat_new)

dupes <- janitor::get_dupes(dat_new)

afldata %>%
  filter(Season == 2017) %>%
  mutate(Round = as.integer((Round))) %>%
  group_by(Season, Round) %>%
  summarise(games = n_distinct(Home.team)) %>%
  arrange(Round) %>%
  print(n = Inf)

# # Write ids file
# id <- afldata %>%
#   ungroup() %>%
#   mutate(
#     Player = paste(First.name, Surname),
#     Team = Playing.for
#   ) %>%
#   select(Season, Player, ID, Team) %>%
#   distinct()
# 
# write_csv(id, here::here("data-raw", "afl_tables_playerstats", "player_ids.csv"))
# 
# # Write data using devtools
# #devtools::use_data(player_stats, overwrite = TRUE)
# write_rds(afldata, here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
# save(afldata, file = here::here("data-raw", "afl_tables_playerstats", "afldata.rda"))
