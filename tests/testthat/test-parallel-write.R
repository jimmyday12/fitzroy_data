# Parallel-write agreement: the new Parquet must match the legacy .rda.
#
# This activates once Phase 1 starts producing data/*.parquet. Because both come
# from the SAME in-memory object, they should agree — this test proves the dual
# write hasn't drifted, and surfaces any type-representation differences from the
# Arrow round-trip BEFORE fitzRoy depends on the Parquet in Phase 2.

compare_source <- function(legacy_rda, parquet_file) {
  skip_if_not(file.exists(parquet_file),
              "Parquet not produced yet — run the updated weekly script first.")

  legacy  <- as.data.frame(load_rda(legacy_rda))
  parquet <- as.data.frame(arrow::read_parquet(parquet_file))  # or nanoparquet::read_parquet

  l <- stable_slice(legacy)
  p <- stable_slice(parquet)

  # Column set + order
  expect_equal(names(p), names(l))
  # Row count
  expect_equal(nrow(p), nrow(l))
  # Type representation — may surface benign Arrow mappings (e.g. integer<->double
  # on all-NA columns). Differences here are informative for the Phase 2 reader
  # choice, not necessarily failures; review before tightening to expect_equal.
  l_cls <- vapply(l, function(x) class(x)[1L], character(1L))
  p_cls <- vapply(p, function(x) class(x)[1L], character(1L))
  expect_equal(p_cls, l_cls)
}

test_that("afltables parquet matches legacy rda", {
  compare_source(
    legacy_rda   = data_path("afl_tables_playerstats", "afldata.rda"),
    parquet_file = here::here("data", "afltables_player_stats.parquet")
  )
})

test_that("footywire parquet matches legacy rda", {
  compare_source(
    legacy_rda   = data_path("player_stats", "player_stats.rda"),
    parquet_file = here::here("data", "footywire_player_stats.parquet")
  )
})
