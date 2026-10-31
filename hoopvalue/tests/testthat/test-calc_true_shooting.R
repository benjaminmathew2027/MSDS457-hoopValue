test_that("true shooting matches a hand calculation", {
  # 30 / (2 * (20 + 0.44 * 8)) = 30 / 47.04
  expect_equal(calc_true_shooting(30, 20, 8), 30 / 47.04)
})

test_that("true shooting works on vectors", {
  result <- calc_true_shooting(c(30, 10), c(20, 10), c(8, 0))
  expect_length(result, 2)
  expect_equal(result[2], 0.5)
})

test_that("zero attempts returns NA instead of Inf or NaN", {
  expect_true(is.na(calc_true_shooting(0, 0, 0)))
  expect_equal(calc_true_shooting(c(10, 0), c(10, 0), c(0, 0)), c(0.5, NA))
})

test_that("bad inputs give clear errors", {
  expect_error(calc_true_shooting("30", 20, 8), "must all be numeric")
  expect_error(calc_true_shooting(c(30, 20), 20, 8), "same length")
})
