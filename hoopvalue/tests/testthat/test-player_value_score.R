make_players <- function() {
  data.frame(
    player = c("A", "B", "C", "D"),
    pts = c(1500, 800, 400, 50), fga = c(1100, 650, 300, 40),
    fta = c(400, 150, 60, 5), ast = c(400, 150, 80, 5),
    orb = c(50, 80, 120, 2), drb = c(300, 250, 400, 10),
    stl = c(80, 50, 40, 2), blk = c(30, 40, 90, 1),
    tov = c(200, 100, 60, 5), minutes = c(2500, 2000, 1800, 100),
    possessions = c(5000, 4000, 3600, 200)
  )
}

test_that("returns a ranked data frame with the new columns", {
  out <- player_value_score(make_players(), min_minutes = 500)
  expect_s3_class(out, "data.frame")
  expect_true(all(c("ts_pct", "pts_100", "value_score", "value_rank") %in% names(out)))
  expect_equal(out$value_rank, seq_len(nrow(out)))
  expect_true(all(diff(out$value_score) <= 0))
})

test_that("min_minutes filters out small samples", {
  out <- player_value_score(make_players(), min_minutes = 500)
  expect_false("D" %in% out$player)
  expect_equal(nrow(player_value_score(make_players(), min_minutes = 0)), 4)
})

test_that("z-scores add up to zero with equal weights on one component", {
  w <- c(ts_pct = 0, pts_100 = 1, ast_100 = 0, reb_100 = 0,
         stocks_100 = 0, tov_100 = 0)
  out <- player_value_score(make_players(), min_minutes = 0, weights = w)
  expect_equal(sum(out$value_score), 0, tolerance = 1e-6)
  expect_equal(out$player[1], "A")
})

test_that("weights change the ranking", {
  rebounds_only <- c(ts_pct = 0, pts_100 = 0, ast_100 = 0, reb_100 = 1,
                     stocks_100 = 0, tov_100 = 0)
  out <- player_value_score(make_players(), weights = rebounds_only)
  expect_equal(out$player[1], "C")
})

test_that("works on the package dataset", {
  out <- player_value_score(nba_players_2026, min_minutes = 1000)
  expect_true(nrow(out) > 100)
  expect_true(all(out$minutes >= 1000))
})

test_that("bad inputs give clear errors", {
  expect_error(player_value_score("not a df"), "must be a data frame")
  expect_error(player_value_score(make_players()[, -1:-2]), "missing these columns")
  expect_error(player_value_score(make_players(), min_minutes = -5), "non-negative")
  expect_error(player_value_score(make_players(), weights = c(2, 1)), "named numeric")
  expect_error(player_value_score(make_players(), weights = c(dunks = 1)), "Unknown weight")
  expect_error(player_value_score(make_players(), min_minutes = 1e6), "Fewer than 2")
})
