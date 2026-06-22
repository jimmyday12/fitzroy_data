# Content invariants on the FROZEN history (Season < STABLE_BEFORE).
#
# Two layers:
#  1. Summary aggregates — fast, human-readable; catches gross regressions
#     (rows lost, a season vanished, players dropped).
#  2. Per-season content hashes — one digest per frozen season. If ANY historical
#     value changes, that season's hash changes. Small to store, strong signal.
#     (It tells you *which* season drifted, though not which cell — for that, use
#     the one-shot waldo comparison in tests/README.md during the migration.)

summary_invariants <- function(df, player_col, match_keys) {
  s <- stable_slice(df)
  list(
    n_rows     = nrow(s),
    season_min = min(s$Season),
    season_max = max(s$Season),
    n_players  = length(unique(s[[player_col]])),
    n_matches  = nrow(unique(s[match_keys]))
  )
}

season_hashes <- function(df, order_cols) {
  s <- stable_slice(df)
  by_season <- split(s, s$Season)
  vapply(by_season, function(x) {
    x <- x[do.call(order, x[order_cols]), , drop = FALSE]  # deterministic row order
    digest::digest(x)
  }, character(1L))
}

test_that("afltables frozen-history invariants are unchanged", {
  df <- load_rda(data_path("afl_tables_playerstats", "afldata.rda"))
  expect_golden(
    summary_invariants(df, player_col = "ID",
                       match_keys = c("Season", "Date", "Home.team", "Away.team")),
    "invariants_afltables"
  )
  expect_golden(season_hashes(df, order_cols = c("ID", "Date", "Surname")),
                "season_hashes_afltables")
})

test_that("footywire frozen-history invariants are unchanged", {
  df <- load_rda(data_path("player_stats", "player_stats.rda"))
  expect_golden(
    summary_invariants(df, player_col = "Player",
                       match_keys = c("Match_id")),
    "invariants_footywire"
  )
  expect_golden(season_hashes(df, order_cols = c("Match_id", "Player")),
                "season_hashes_footywire")
})
