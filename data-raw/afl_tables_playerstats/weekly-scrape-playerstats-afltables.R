# Script to get data from afltables
library(fitzRoy)
library(dplyr)
library(readr)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda
end_year <- as.numeric(format(Sys.Date(), "%Y"))
seasons <- 1897:end_year
afldata <- fetch_player_stats_afltables(seasons)

# remove duplicate games if exist
afldata <- distinct(afldata)

# Check for Browlow missing - these will always be empty in current season but 
# get updated after season finishes
brownlow_date <- lubridate::ymd(paste0(end_year, "-10-01")) # approx

if (Sys.Date() > brownlow_date) {
brownlow_year <- end_year
} else {
  brownlow_year <- end_year - 1
}

brownlow_start <- lubridate::ymd(paste0(brownlow_year, "-1-01"))
brownlow_end <- lubridate::ymd(paste0(brownlow_year, "-12-31"))

# get data from either last year or this year (if past Oct 1st)
brownlow_games <- afldata %>%
  filter(Date > brownlow_start & Date < brownlow_end)

missing_votes <- any(is.na(brownlow_games$Brownlow.Votes))

# If missing votes, rescrape
if (missing_votes) {
  urls <- fitzRoy:::get_afltables_urls(brownlow_start, brownlow_end)
  dat_new <- fitzRoy:::scrape_afltables_match(urls)
  
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

  # Filter out these dates from afldata
  other_games_pre <- afldata %>%
    filter(Date < brownlow_start)
  
  other_games_post <- afldata %>%
    filter(Date > brownlow_end)
  
  afldata <- bind_rows(other_games_pre, dat_new, other_games_post) %>%
    distinct()
    
}

#afldata_old <- afldata %>% select(-Brownlow.Votes)
#afldata_new1 <- afldata_new %>% select(-Brownlow.Votes)
#anti_join(afldata_old, afldata_new1)

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


#x <- readRDS(here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
