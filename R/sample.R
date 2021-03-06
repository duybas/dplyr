#' Sample n rows from a table.
#'
#' This is a wrapper around [sample.int()] to make it easy to
#' select random rows from a table. It currently only works for local
#' tbls.
#'
#' @param tbl tbl of data.
#' @param size For `sample_n()`, the number of rows to select.
#'   For `sample_frac()`, the fraction of rows to select.
#'   If `tbl` is grouped, `size` applies to each group.
#' @param replace Sample with or without replacement?
#' @param weight Sampling weights. This variable is passed by
#'   expression and evaluated in the context of the data frame. It
#'   supports [unquoting][rlang::quasiquotation]. It must return a
#'   vector of non-negative numbers the same length as the
#'   input. Weights are automatically standardised to sum to 1.
#' @param .env This variable is deprecated and no longer has any
#'   effect. To evaluate `weight` in a particular context, you can
#'   now unquote a [quosure][rlang::quosure].
#' @name sample
#' @examples
#' by_cyl <- mtcars %>% group_by(cyl)
#'
#' # Sample fixed number per group
#' sample_n(mtcars, 10)
#' sample_n(mtcars, 50, replace = TRUE)
#' sample_n(mtcars, 10, weight = mpg)
#'
#' sample_n(by_cyl, 3)
#' sample_n(by_cyl, 10, replace = TRUE)
#' sample_n(by_cyl, 3, weight = mpg / mean(mpg))
#'
#' # Sample fixed fraction per group
#' # Default is to sample all data = randomly resample rows
#' sample_frac(mtcars)
#'
#' sample_frac(mtcars, 0.1)
#' sample_frac(mtcars, 1.5, replace = TRUE)
#' sample_frac(mtcars, 0.1, weight = 1 / mpg)
#'
#' sample_frac(by_cyl, 0.2)
#' sample_frac(by_cyl, 1, replace = TRUE)
NULL

#' @rdname sample
#' @export
sample_n <- function(tbl, size, replace = FALSE, weight = NULL, .env = NULL) {
  UseMethod("sample_n")
}

#' @rdname sample
#' @export
sample_frac <- function(tbl, size = 1, replace = FALSE, weight = NULL, .env = NULL) {
  UseMethod("sample_frac")
}

# Data frames (and tbl_df) -----------------------------------------------------

# Grouped data frames ----------------------------------------------------------


# Default method ---------------------------------------------------------------

#' @export
sample_n.default <- function(tbl, size, replace = FALSE, weight = NULL,
                             .env = parent.frame()) {

  stop(
    "Don't know how to sample from objects of class ", class(tbl)[1],
    call. = FALSE
  )
}

#' @export
sample_frac.default <- function(tbl, size = 1, replace = FALSE, weight = NULL,
                                .env = parent.frame()) {

  stop(
    "Don't know how to sample from objects of class ", class(tbl)[1],
    call. = FALSE
  )
}

# Helper functions -------------------------------------------------------------

check_weight <- function(x, n) {
  if (is.null(x)) return()

  if (!is.numeric(x)) {
    stop("Weights must be numeric", call. = FALSE)
  }
  if (any(x < 0)) {
    stop("Weights must all be greater than 0", call. = FALSE)
  }
  if (length(x) != n) {
    stop("Weights must be same length as data (", n, ")", call. = FALSE)
  }

  x / sum(x)
}

check_size <- function(size, n, replace = FALSE) {
  if (size <= n || replace) return()

  stop(
    "Sample size (", size, ") greater than population size (", n, ").",
    " Do you want replace = TRUE?",
    call. = FALSE
  )
}
