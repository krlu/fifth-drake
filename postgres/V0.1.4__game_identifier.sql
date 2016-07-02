CREATE TABLE league.game_identifier(
  id SERIAL PRIMARY KEY,
  match_id TEXT NOT NULL,
  game_id TEXT NOT NULL,
  game_date TEXT NOT NULL,
  team_acronym_1 TEXT NOT NULL,
  team_acronym_2 TEXT NOT NULL,
  game_number INTEGER NOT NULL
);
