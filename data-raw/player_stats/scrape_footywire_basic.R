# Script to get data from footywire - adapted from Rob's earlier one
library(fitzRoy)
library(fst)
library(dplyr)
library(cli)

# Run function on range of id's ----
# I've got a list of ID's that I scraped in a file called id_data.rda
rescrape = TRUE
end_year <- as.numeric(format(Sys.Date(), "%Y"))
seasons <- 1897:end_year

cli::cli_progress_step("Getting existing footywire player stats")
player_stats <- fetch_player_stats_footywire(season = seasons, 
                                             round_number = NULL, 
                                             check_existing = TRUE)
if (rescrape){
  cli::cli_progress_step("Rescraping footywire player stats")
  player_stats_existing <- player_stats
  player_stats_re_scrape<- fetch_player_stats_footywire(season = seasons, 
                                                        round_number = NULL, 
                                                        check_existing = FALSE)
  
  
  cli::cli_progress_step("Saving rescraped footywire player stats")
  save(player_stats_re_scrape, 
       file = here::here("data-raw", "player_stats", "player_stats_re_scrape.rda"), 
       version = 2)

  player_stats <- player_stats_re_scrape
}

cli::cli_progress_step("Tidying footywire player stats")
player_stats <- player_stats %>% 
  ungroup() %>% 
  distinct()

#load(here::here("data-raw", "player_stats", "player_stats.rda"))

# Write data using devtools
#devtools::use_data(player_stats, overwrite = TRUE)
cli::cli_progress_step("Saving footywire player stats")
save(player_stats, 
     file = here::here("data-raw", "player_stats", "player_stats.rda"), 
     version = 2)

save(player_stats, 
     file = here::here("data-raw", "player_stats", "player_stats_end2020.rda"), 
     version = 2)

fst::write_fst(player_stats, 
               path = here::here("data-raw", "player_stats", "player_stats.fst"))

fst::write_fst(player_stats, 
               path = here::here("data-raw", "player_stats", "player_stats_full.fst"), 
               compress = 100)
