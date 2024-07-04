# Benchmarking for loading data

load_rda <- function() {
dat_url <- url("https://github.com/jimmyday12/fitzRoy_data/raw/main/data-raw/player_stats/player_stats.rda")

load_r_data <- function(fname) {
  load(fname)
  get(ls()[ls() != "fname"])
}

cli::cli_progress_step("fetching cached data from {.url github.com/jimmyday12/fitzRoy_data}")
dat <- load_r_data(dat_url)

as_tibble(dat)
}


load_feather <- function() {
  dat <- arrow::read_feather("https://github.com/jimmyday12/fitzRoy_data/raw/main/data-raw/player_stats/player_stats.feather")
  as_tibble(dat)
                      
}

load_fst <- function() {
  
  tmp_file <- tempfile()
  fst_url <- "https://github.com/jimmyday12/fitzRoy_data/raw/main/data-raw/player_stats/player_stats.fst"
  curl::curl_download(fst_url, tmp_file, mode="wb")
  dat <- fst::read_fst(tmp_file)
  as_tibble(dat)
}

load_csv <- function() {
  dat <- readr::read_csv("https://github.com/jimmyday12/fitzRoy_data/raw/main/data-raw/player_stats/player_stats.csv")
  as_tibble(dat)
}

microbenchmark::microbenchmark(load_rda(), load_feather(), load_fst(), load_csv(), times = 10)
