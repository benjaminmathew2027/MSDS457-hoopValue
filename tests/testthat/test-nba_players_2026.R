test_that("dataset has the expected structure", {
  expect_s3_class(nba_players_2026, "data.frame")
  expect_true(all(c("player", "team", "pts", "fga", "fta", "possessions") %in%
                    names(nba_players_2026)))
  expect_false(anyDuplicated(nba_players_2026$athlete_id) > 0)
  expect_true(all(nba_players_2026$position %in% c("G", "F", "C")))
})

test_that("package functions work on the dataset", {
  ts <- calc_true_shooting(nba_players_2026$pts, nba_players_2026$fga,
                           nba_players_2026$fta)
  expect_length(ts, nrow(nba_players_2026))
  expect_true(all(ts[!is.na(ts)] >= 0))
})
