# Weekly Script to update data
#devtools::load_all(".")
#devtools::install_github("jimmyday12/fitzRoy", ref = "issue-189")
library(here)
library(tidyverse)
library(fitzRoy)
# setwd("~/Documents/R_scripts/fitzRoy")
# write out server time
#cat(as.character(Sys.time()), file = "time_changed.txt" , sep="\n")

# IDS -----------------------------------------------------------
#source(here::here("data-raw", "Match_ids", "find_ids.R"))

# player_stats ------------------------------------------------------------
source(here::here("data-raw", "player_stats", "scrape_footywire_basic.R"))
source(here::here("data-raw", "afl_tables_playerstats", "weekly-scrape-playerstats-afltables.R"))

# Match results -----------------------------------------------------------
source(here::here("data-raw", "afl_tables_match_results", "initial_match_results.R"))



# weather -----------------------------------------------------------------
# Need to work out how to update this one
# source(here::here("data-raw", "weather", "BOM Data.R"))

# score progression -------------------------------------------------------
# Need this one to be update for 2018 data - currently works for 2008-2017
# source(here::here("data-raw", "scoring_progression", "score_progression_transform.R"))
