context("top_n")

test_that("top_n returns n rows", {
  test_df <- data.frame(x = 1:10, y = 11:20)
  top_four <- test_df %>% top_n(4, y)
  expect_equal(dim(top_four), c(4, 2))
})

test_that("top_n errs if wt argument is not a symbol (#2279)", {
  expect_error(
    data.frame(x = 1:10) %>% top_n(10, "x"),
    "is_symbol",
    fixed = TRUE
  )
})

test_that("top_n() handles missing `wt`", {
  df <- data.frame(x = c(10, 4, 1, 6, 3, 1, 1))
  expect_message(regexp = "Selecting by x",
    expect_identical(top_n(df, 2)$x, c(10, 6))
  )
})
