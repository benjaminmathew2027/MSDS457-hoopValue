# hoopvalue

hoopvalue is an R package for measuring the value of NBA players with advanced analytics. It is being built as a final project for a sports management analytics course.

## Installation

```r
# install.packages("remotes")
remotes::install_github("benjaminmathew2027/hoopvalue")
```

## Current functions

| Function | What it does |
|---|---|
| `calc_true_shooting()` | Calculates true shooting percentage from points, field goal attempts, and free throw attempts |
| `calc_per_100()` | Converts a stat total to a per 100 possession rate |

## Example

```r
library(hoopvalue)

calc_true_shooting(pts = 30, fga = 20, fta = 8)
#> [1] 0.6377551

calc_per_100(stat = 1500, possessions = 2400)
#> [1] 62.5
```
