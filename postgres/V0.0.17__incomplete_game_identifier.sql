CREATE TABLE league.incomplete_game_identifier(
  id SERIAL PRIMARY KEY,
  game_key TEXT NOT NULL,
  blue_team TEXT,
  red_team TEXT,
  game_number INTEGER NOT NULL,
  in_game_hash TEXT NOT NULL,
  series_hash TEXT NOT NULL,
  realm TEXT NOT NULL,
);

