context("SQL: joins")

src <- src_sqlite(tempfile(), create = TRUE)
df1 <- copy_to(src, data.frame(x = 1:5, y = 1:5), "df1")
df2 <- copy_to(src, data.frame(a = 5:1, b = 1:5), "df2")
df3 <- copy_to(src, data.frame(x = 1:5, z = 1:5), "df3")
df4 <- copy_to(src, data.frame(a = 5:1, z = 5:1), "df4")
fam <- copy_to(src, data.frame(id = 1:5, parent = c(NA, 1, 2, 2, 4)), "fam")

test_that("named by join by different x and y vars", {
  skip_if_no_sqlite()

  j1 <- collect(inner_join(df1, df2, c("x" = "a")))
  expect_equal(names(j1), c("x", "y", "b"))
  expect_equal(nrow(j1), 5)

  j2 <- collect(inner_join(df1, df2, c("x" = "a", "y" = "b")))
  expect_equal(names(j2), c("x", "y"))
  expect_equal(nrow(j2), 1)
})

test_that("named by join by same z vars", {
  skip_if_no_sqlite()

  j1 <- collect(inner_join(df3, df4, c("z" = "z")))
  expect_equal(nrow(j1), 5)
  expect_equal(names(j1), c("x", "z", "a"))
})

test_that("join with both same and different vars", {
  skip_if_no_sqlite()

  j1 <- collect(left_join(df1, df3, by = c("y" = "z", "x")))
  expect_equal(nrow(j1), 5)
  expect_equal(names(j1), c("x", "y"))
})

test_that("inner join doesn't result in duplicated columns ", {
  skip_if_no_sqlite()
  expect_equal(colnames(dplyr::inner_join(df1, df1)), c("x", "y"))
})

test_that("self-joins allowed with named by", {
  skip_if_no_sqlite()
  fam <- memdb_frame(id = 1:5, parent = c(NA, 1, 2, 2, 4))

  j1 <- fam %>% left_join(fam, by = c("parent" = "id"))
  j2 <- fam %>% inner_join(fam, by = c("parent" = "id"))

  expect_equal(op_vars(j1), c("id", "parent.x", "parent.y"))
  expect_equal(op_vars(j2), c("id", "parent.x", "parent.y"))
  expect_equal(nrow(collect(j1)), 5)
  expect_equal(nrow(collect(j2)), 4)

  j3 <- collect(semi_join(fam, fam, by = c("parent" = "id")))
  j4 <- collect(anti_join(fam, fam, by = c("parent" = "id")))

  expect_equal(j3, filter(collect(fam), !is.na(parent)))
  expect_equal(j4, filter(collect(fam), is.na(parent)))
})

test_that("suffix modifies duplicated variable names", {
  skip_if_no_sqlite()
  j1 <- collect(inner_join(fam, fam, by = c("parent" = "id"), suffix = c("1", "2")))
  j2 <- collect(left_join(fam, fam, by = c("parent" = "id"), suffix = c("1", "2")))

  expect_named(j1, c("id", "parent1", "parent2"))
  expect_named(j2, c("id", "parent1", "parent2"))
})
