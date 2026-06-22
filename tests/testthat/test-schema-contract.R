# Schema contract: column names + R classes must not change.
#
# This is the cheapest, highest-value guard. It catches a dropped/renamed column
# or a type flip (e.g. integer -> double) the instant the cleanup introduces it.
# The captured fixture is the authoritative type pin — derived from your real R
# data, not inferred — which resolves the int-vs-double question we couldn't
# settle outside R.

schema_of <- function(df) {
  list(
    columns = names(df),
    classes = vapply(df, function(x) paste(class(x), collapse = "/"), character(1L))
  )
}

test_that("afltables player stats schema is stable", {
  df <- load_rda(data_path("afl_tables_playerstats", "afldata.rda"))
  expect_golden(schema_of(df), "schema_afltables")
})

test_that("footywire player stats schema is stable", {
  df <- load_rda(data_path("player_stats", "player_stats.rda"))
  expect_golden(schema_of(df), "schema_footywire")
})
