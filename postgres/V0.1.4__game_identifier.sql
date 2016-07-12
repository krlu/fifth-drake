CREATE TABLE league.game_identifier(
  id SERIAL PRIMARY KEY,
  game_key TEXT NOT NULL,
  game_date TEXT NOT NULL,
  team_1 TEXT,
  team_2 TEXT
);
