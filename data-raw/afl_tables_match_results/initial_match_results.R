library(fitzRoy)

end_year <- as.numeric(format(Sys.Date(), "%Y"))
seasons <- 1897:end_year
cli::cli_progress_step("Fetching afltables match data")
match_results <- fetch_results_afltables(seasons)

# Write data using devtools
#devtools::use_data(match_results, overwrite = TRUE)
cli::cli_progress_step("Saving afltables match data")
save(match_results, file = here::here("data-raw", "afl_tables_match_results", "match_results.rda"), version = 2)
