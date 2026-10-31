# hoopvalue

hoopvalue is an R package for measuring the value of NBA players with advanced analytics. It turns box score totals into efficiency and per 100 possession measures, combines them into one overall value score, and includes season totals for every player from the 2025-26 NBA regular season.

## Who it is for

- **Analysts and students** who want tested, documented functions for common basketball metrics instead of rewriting formulas by hand.
- **Front office staff and coaches** who want a quick way to rank and compare players.
- **Fans** who want to go beyond points per game when debating who the best players are.

No basketball analytics background is needed. Each function's help page explains what the metric means and how it is calculated.

## Installation

```r
# install.packages("remotes")
remotes::install_github("benjaminmathew2027/MSDS457-hoopValue")
```

## What is included

| Function or dataset | What it does |
|---|---|
| `nba_players_2026` | Season totals for all 582 players who appeared in a 2025-26 regular season game |
| `calc_true_shooting()` | True shooting percentage from points, field goal attempts, and free throw attempts |
| `calc_per_100()` | Converts any stat total to a per 100 possession rate |
| `player_value_score()` | Combines six advanced stats into one value score with adjustable weights |

## Basic usage

```r
library(hoopvalue)

# True shooting percentage for one player
calc_true_shooting(pts = 30, fga = 20, fta = 8)
#> [1] 0.6377551

# Points per 100 possessions for every player in the dataset
nba_players_2026$pts_100 <- calc_per_100(nba_players_2026$pts,
                                         nba_players_2026$possessions)

# Top 5 players by overall value score (1,000+ minutes)
scores <- player_value_score(nba_players_2026, min_minutes = 1000)
head(scores[, c("value_rank", "player", "team", "value_score")], 5)
```

For a full walkthrough, see `vignette("getting-started", package = "hoopvalue")`.

## Data and assumptions

Player totals are built from ESPN box score data loaded with the hoopR package. The script that builds the dataset is in `data-raw/`. Box scores do not record individual possessions, so the `possessions` column is an estimate based on each team's possessions and the share of each game a player was on the court. See `?nba_players_2026` for details.

## Citation

Saiem Gilani, *hoopR: Access Men's Basketball Play by Play Data*, version 3.1.0, R package, 2026, https://github.com/sportsdataverse/hoopR.

Sports Reference LLC, "Glossary," Basketball-Reference.com, accessed October 30, 2026, https://www.basketball-reference.com/about/glossary.html.

## License

MIT. See `LICENSE.md`.
