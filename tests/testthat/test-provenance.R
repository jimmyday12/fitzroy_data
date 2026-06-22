# Provenance integrity — insurance against fat-fingering the irreplaceable files
# during the cleanup. None of these are read by the running pipeline, so nothing
# else would notice if one were deleted or corrupted. This test would.
#
# afltables_playerstats_provided.rda is the manual seed from the afltables owner
# and CANNOT be re-scraped. Treat a failure here as a stop-the-line event.

test_that("irreplaceable provenance files are present and unchanged", {
  files <- c(
    data_path("afl_tables_playerstats", "afltables_playerstats_provided.rda"),
    data_path("afl_tables_playerstats", "afltables_raw.rda"),
    data_path("afl_tables_playerstats", "afltables_playerstats_2017.csv")
  )

  missing <- files[!file.exists(files)]
  expect_true(length(missing) == 0L,
              info = paste("MISSING provenance file(s):", paste(missing, collapse = ", ")))

  hashes <- vapply(files, function(f) {
    if (file.exists(f)) unname(tools::md5sum(f)) else NA_character_
  }, character(1L))
  expect_golden(hashes, "provenance_checksums")
})
