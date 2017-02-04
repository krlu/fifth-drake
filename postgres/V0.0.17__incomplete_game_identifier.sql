CREATE TABLE league.incomplete_game_identifier(
  id SERIAL PRIMARY KEY,
  game_key TEXT NOT NULL,
  game_date TEXT NOT NULL,
  red_team TEXT,
  blue_team TEXT
);
