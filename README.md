# hoopvalue

hoopvalue is an R package for measuring the value of NBA players with advanced analytics. It turns box score totals into efficiency and per-possession measures, combines them into one overall value score, and ships with season totals for every player from the 2025-26 NBA regular season.

It is being built as the final project for a sports management analytics course.

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

## Example

```r
library(hoopvalue)

# True shooting percentage for one player
calc_true_shooting(pts = 30, fga = 20, fta = 8)
#> [1] 0.6377551

# Top 5 players by overall value score (1,000+ minutes)
scores <- player_value_score(nba_players_2026, min_minutes = 1000)
head(scores[, c("value_rank", "player", "team", "value_score")], 5)
```

See `vignette("getting-started", package = "hoopvalue")` for a full walkthrough.

## Data source

Player totals are built from ESPN box score data loaded with the hoopR package (Saiem Gilani, *hoopR: Access Men's Basketball Play by Play Data*, version 3.1.0, 2026, https://github.com/sportsdataverse/hoopR). The script that builds the dataset is in `data-raw/`.
