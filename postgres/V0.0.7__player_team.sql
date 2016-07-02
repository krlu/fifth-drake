CREATE TABLE league.player_team (
  id SERIAL PRIMARY KEY,
  player_id INTEGER REFERENCES league.player(id),
  team_id INTEGER REFERENCES league.team(id),
  is_starter BOOLEAN NOT NULL,
  role TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE
)
;