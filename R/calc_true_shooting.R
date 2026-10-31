#' Calculate true shooting percentage
#'
#' True shooting percentage measures how efficiently a player scores. It
#' accounts for two-point shots, three-point shots, and free throws in a
#' single number, using the formula `PTS / (2 * (FGA + 0.44 * FTA))`.
#'
#' @param pts Numeric vector of points scored.
#' @param fga Numeric vector of field goal attempts.
#' @param fta Numeric vector of free throw attempts.
#'
#' @return A numeric vector of true shooting percentages on a 0 to 1 scale,
#'   the same length as the inputs. Returns `NA` for any player with no
#'   field goal or free throw attempts.
#'
#' @details The 0.44 multiplier estimates the share of free throw attempts
#'   that end a possession, since and-ones, technical fouls, and three-shot
#'   fouls mean not every pair of free throws uses a full possession.
#'
#' @references Sports Reference LLC, "Glossary," Basketball-Reference.com,
#'   <https://www.basketball-reference.com/about/glossary.html>.
#'
#' @seealso [calc_per_100()] for scoring volume, and [player_value_score()],
#'   which uses true shooting as one of its components.
#' @family player metrics
#' @export
#'
#' @examples
#' # One player: 30 points on 20 field goal attempts and 8 free throw attempts
#' calc_true_shooting(pts = 30, fga = 20, fta = 8)
#'
#' # Several players at once, including one with no attempts
#' calc_true_shooting(pts = c(30, 12, 0), fga = c(20, 10, 0), fta = c(8, 2, 0))
calc_true_shooting <- function(pts, fga, fta) {
  if (!is.numeric(pts) || !is.numeric(fga) || !is.numeric(fta)) {
    stop("`pts`, `fga`, and `fta` must all be numeric.", call. = FALSE)
  }
  if (length(unique(c(length(pts), length(fga), length(fta)))) != 1) {
    stop("`pts`, `fga`, and `fta` must be the same length.", call. = FALSE)
  }

  shooting_possessions <- 2 * (fga + 0.44 * fta)
  ifelse(shooting_possessions == 0, NA_real_, pts / shooting_possessions)
}
