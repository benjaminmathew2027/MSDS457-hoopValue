# Builds the nba_players_2026 dataset from ESPN box scores through hoopR.
# Run this script to update the data, then rebuild the documentation.

library(hoopR)
library(dplyr)

espn_to_nba <- c(GS = "GSW", NY = "NYK", NO = "NOP", SA = "SAS",
                 UTAH = "UTA", WSH = "WAS")
nba_teams <- c("ATL", "BKN", "BOS", "CHA", "CHI", "CLE", "DAL", "DEN",
               "DET", "GS", "HOU", "IND", "LAC", "LAL", "MEM", "MIA",
               "MIL", "MIN", "NO", "NY", "OKC", "ORL", "PHI", "PHX",
               "POR", "SA", "SAC", "TOR", "UTAH", "WSH")

team_box   <- load_nba_team_box(2026)
player_box <- load_nba_player_box(2026)

team_reg <- team_box %>%
  filter(season_type == 2,
         team_abbreviation %in% nba_teams,
         opponent_team_abbreviation %in% nba_teams)

# The NBA Cup championship game does not count in regular season stats.
# It is the only game on its date, and both teams would otherwise have 83 games.
cup_final <- team_reg %>%
  add_count(team_abbreviation, name = "team_games") %>%
  group_by(game_id, game_date) %>%
  summarise(both_over = all(team_games > 82), .groups = "drop") %>%
  add_count(game_date, name = "games_on_date") %>%
  filter(both_over, games_on_date == 1) %>%
  pull(game_id)

# Team possessions per game, used to estimate the possessions each player played
team_pace <- team_reg %>%
  filter(!game_id %in% cup_final) %>%
  mutate(poss = field_goals_attempted + 0.44 * free_throws_attempted -
           offensive_rebounds + turnovers) %>%
  group_by(team_abbreviation, game_id) %>%
  summarise(poss = sum(poss), .groups = "drop")

player_games <- player_box %>%
  filter(season_type == 2,
         team_abbreviation %in% nba_teams,
         opponent_team_abbreviation %in% nba_teams,
         !game_id %in% cup_final,
         !did_not_play, !is.na(minutes), minutes > 0) %>%
  left_join(team_pace, by = c("team_abbreviation", "game_id")) %>%
  mutate(est_possessions = poss * minutes / 48,
         position = case_when(
           athlete_position_abbreviation %in% c("G", "PG", "SG") ~ "G",
           athlete_position_abbreviation %in% c("F", "SF", "PF") ~ "F",
           athlete_position_abbreviation == "C" ~ "C",
           TRUE ~ NA_character_))

nba_players_2026 <- player_games %>%
  arrange(athlete_id, game_date) %>%
  group_by(athlete_id) %>%
  summarise(
    player      = stringi::stri_trans_general(last(athlete_display_name), "Latin-ASCII"),
    team        = last(team_abbreviation),
    position    = names(which.max(table(position))),
    games       = n(),
    minutes     = round(sum(minutes), 1),
    possessions = round(sum(est_possessions, na.rm = TRUE), 1),
    pts  = sum(points),
    fgm  = sum(field_goals_made),
    fga  = sum(field_goals_attempted),
    fg3m = sum(three_point_field_goals_made),
    fg3a = sum(three_point_field_goals_attempted),
    ftm  = sum(free_throws_made),
    fta  = sum(free_throws_attempted),
    orb  = sum(offensive_rebounds),
    drb  = sum(defensive_rebounds),
    ast  = sum(assists),
    stl  = sum(steals),
    blk  = sum(blocks),
    tov  = sum(turnovers),
    pf   = sum(fouls),
    .groups = "drop"
  ) %>%
  mutate(team = recode(team, !!!espn_to_nba),
         athlete_id = as.integer(athlete_id),
         across(c(games, pts:pf), as.integer)) %>%
  select(player, athlete_id, team, position, everything()) %>%
  arrange(desc(pts)) %>%
  as.data.frame()

usethis::use_data(nba_players_2026, overwrite = TRUE)
