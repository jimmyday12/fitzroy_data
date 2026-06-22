# Data contract tests

A small, focused safety net for the `fitzroy_data` cleanup. The job of these
tests is to prove that rewriting the pipeline (consolidating formats, adding
Parquet, deleting cruft) does **not** silently change the data fitzRoy serves.

## The idea: golden-master / characterization

These aren't tests of "correct AFL stats" — they're tests of "the same as
before". On the **first run**, each test captures the current reality into
`tests/testthat/_fixtures/` and skips. On **every later run**, it compares
against that captured truth.

So the workflow is:

1. **Before changing anything**, run the suite once to capture fixtures.
2. Eyeball the captured fixtures, then **commit `_fixtures/`**. This is your
   frozen contract.
3. From now on the suite is a regression gate — run it after every change.

If you capture fixtures *after* a broken refactor, they just encode the
breakage. Capture first.

## What's covered

| Test | Guards against |
|---|---|
| `test-schema-contract` | dropped/renamed columns, type flips (the captured classes are the authoritative type pin) |
| `test-invariants` | rows lost, a season vanishing, players dropped; per-season hashes flag *which* frozen season drifted |
| `test-provenance` | the irreplaceable seed/bootstrap files being deleted or corrupted during cleanup |
| `test-parallel-write` | the new Parquet drifting from the legacy `.rda` (skips until `data/*.parquet` exists) |

### Why only the "frozen" slice?

The two most recent seasons are re-scraped weekly, so their values legitimately
change. Exact-value checks run only on `Season < STABLE_BEFORE`
(see `helper-data.R`). The schema test covers all rows; the value/hash tests
cover frozen history.

## The one-shot migration check (not a committed test)

The strongest check — "the refactored script reproduces the old file exactly" —
needs the pre-change file as a reference, which is too big to commit. Run it
locally during the migration instead:

```r
source("tests/testthat/helper-data.R")

old <- load_rda("~/backup/afldata.rda")                               # pre-change copy
new <- load_rda("data-raw/afl_tables_playerstats/afldata.rda")        # after refactor

waldo::compare(stable_slice(old), stable_slice(new))                  # expect: no differences
```

Grab the `old` copy from a git checkout of the pre-change commit, or just back up
the file before you start.

## Running

```r
testthat::test_dir("tests/testthat")
# or: Rscript tests/testthat.R
```

## Dependencies

`testthat` (>= 3e), `here`, `dplyr`, `digest`, `waldo`, and a Parquet reader
(`arrow` or `nanoparquet`) for the parallel-write test.

## Later: wire into the weekly Action

Once green, add a step at the **end** of each weekly workflow that runs the suite
against the freshly-built data and fails the run on a contract violation — so a
bad scrape fails loudly instead of publishing.
