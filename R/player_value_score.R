#' Calculate an overall player value score
#'
#' Combines several advanced statistics into one score so players can be
#' ranked on overall on-court value instead of a single stat. Each component
#' is converted to a z-score (how many standard deviations a player is above
#' or below the average of the players in `data`), multiplied by its weight,
#' and added together. Turnovers count against a player.
#'
#' The components are:
#' * `ts_pct`: true shooting percentage, from [calc_true_shooting()]
#' * `pts_100`: points per 100 possessions, from [calc_per_100()]
#' * `ast_100`: assists per 100 possessions
#' * `reb_100`: total rebounds per 100 possessions
#' * `stocks_100`: steals plus blocks per 100 possessions
#' * `tov_100`: turnovers per 100 possessions (weighted negatively)
#'
#' @param data A data frame of player season totals with the columns `pts`,
#'   `fga`, `fta`, `ast`, `orb`, `drb`, `stl`, `blk`, `tov`, `minutes`, and
#'   `possessions`, such as [nba_players_2026].
#' @param min_minutes Minimum minutes a player needs to be included. Players
#'   below this are dropped before scores are calculated, so small samples do
#'   not distort the averages. Defaults to 500.
#' @param weights A named numeric vector of weights for the components. Any
#'   component left out keeps its default weight of 1. Use a weight of 0 to
#'   ignore a component.
#'
#' @return The input data frame, filtered to players with at least
#'   `min_minutes`, with the six component columns, a `value_score` column,
#'   and a `value_rank` column (1 = highest score). Sorted by `value_score`
#'   from highest to lowest.
#'
#' @export
#'
#' @examples
#' scores <- player_value_score(nba_players_2026, min_minutes = 1000)
#' head(scores[, c("player", "team", "value_score", "value_rank")])
#'
#' # Give scoring efficiency twice as much weight
#' player_value_score(nba_players_2026, weights = c(ts_pct = 2))[1:5, "player"]
player_value_score <- function(data, min_minutes = 500, weights = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  required <- c("pts", "fga", "fta", "ast", "orb", "drb", "stl", "blk",
                "tov", "minutes", "possessions")
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0) {
    stop("`data` is missing these columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }
  if (!is.numeric(min_minutes) || length(min_minutes) != 1 ||
      is.na(min_minutes) || min_minutes < 0) {
    stop("`min_minutes` must be a single non-negative number.", call. = FALSE)
  }

  default_weights <- c(ts_pct = 1, pts_100 = 1, ast_100 = 1, reb_100 = 1,
                       stocks_100 = 1, tov_100 = 1)
  if (!is.null(weights)) {
    if (!is.numeric(weights) || is.null(names(weights)) ||
        any(names(weights) == "")) {
      stop("`weights` must be a named numeric vector.", call. = FALSE)
    }
    bad <- setdiff(names(weights), names(default_weights))
    if (length(bad) > 0) {
      stop("Unknown weight name(s): ", paste(bad, collapse = ", "),
           ". Valid names are: ", paste(names(default_weights), collapse = ", "),
           ".", call. = FALSE)
    }
    default_weights[names(weights)] <- weights
  }

  out <- data[data$minutes >= min_minutes, , drop = FALSE]
  if (nrow(out) < 2) {
    stop("Fewer than 2 players have at least `min_minutes` minutes. ",
         "Try a lower value.", call. = FALSE)
  }

  out$ts_pct     <- calc_true_shooting(out$pts, out$fga, out$fta)
  out$pts_100    <- calc_per_100(out$pts, out$possessions)
  out$ast_100    <- calc_per_100(out$ast, out$possessions)
  out$reb_100    <- calc_per_100(out$orb + out$drb, out$possessions)
  out$stocks_100 <- calc_per_100(out$stl + out$blk, out$possessions)
  out$tov_100    <- calc_per_100(out$tov, out$possessions)

  z <- function(x) {
    s <- stats::sd(x, na.rm = TRUE)
    if (is.na(s) || s == 0) return(rep(0, length(x)))
    (x - mean(x, na.rm = TRUE)) / s
  }
  sign <- c(ts_pct = 1, pts_100 = 1, ast_100 = 1, reb_100 = 1,
            stocks_100 = 1, tov_100 = -1)

  score <- 0
  for (comp in names(default_weights)) {
    zc <- z(out[[comp]])
    zc[is.na(zc)] <- 0
    score <- score + sign[[comp]] * default_weights[[comp]] * zc
  }

  out$value_score <- round(score, 3)
  out <- out[order(-out$value_score), , drop = FALSE]
  out$value_rank <- seq_len(nrow(out))
  rownames(out) <- NULL
  out
}
