test_that("per 100 matches a hand calculation", {
  expect_equal(calc_per_100(1500, 2400), 62.5)
})

test_that("per 100 works on vectors", {
  expect_equal(calc_per_100(c(1500, 800), c(2400, 1600)), c(62.5, 50))
})

test_that("zero possessions returns NA", {
  expect_true(is.na(calc_per_100(10, 0)))
})

test_that("bad inputs give clear errors", {
  expect_error(calc_per_100("10", 100), "must both be numeric")
  expect_error(calc_per_100(c(10, 20), 100), "same length")
})
