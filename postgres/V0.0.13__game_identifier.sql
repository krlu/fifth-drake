CREATE TABLE league.game_identifier(
  id SERIAL PRIMARY KEY,
  game_key TEXT NOT NULL,
  blue_team TEXT,
  red_team TEXT,
  game_date date NOT NULL,
  week Text NOT NULL,
  split TEXT NOT NULL,
  series_hash TEXT NOT NULL,
  mongo collection TEXT NOT NULL
);
