#' Convert a stat total to a per 100 possession rate
#'
#' Raw totals depend on how fast a team plays. Converting a stat to a per
#' 100 possession rate puts players on fast and slow teams on the same
#' scale so they can be compared fairly.
#'
#' @param stat Numeric vector of stat totals, such as points or rebounds.
#' @param possessions Numeric vector of possessions played.
#'
#' @return A numeric vector of per 100 possession rates, the same length as
#'   the inputs. Returns `NA` for any player with zero possessions.
#'
#' @export
#'
#' @examples
#' # 1,500 points over 2,400 possessions
#' calc_per_100(stat = 1500, possessions = 2400)
#'
#' # Several players at once, including one with no possessions
#' calc_per_100(stat = c(1500, 800, 0), possessions = c(2400, 1600, 0))
calc_per_100 <- function(stat, possessions) {
  if (!is.numeric(stat) || !is.numeric(possessions)) {
    stop("`stat` and `possessions` must both be numeric.", call. = FALSE)
  }
  if (length(stat) != length(possessions)) {
    stop("`stat` and `possessions` must be the same length.", call. = FALSE)
  }

  ifelse(possessions == 0, NA_real_, stat / possessions * 100)
}
