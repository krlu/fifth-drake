CREATE TABLE league.game_identifier(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_key TEXT NOT NULL,
  blue_team INTEGER REFERENCES league.team(id),
  red_team INTEGER REFERENCES league.team(id),
  game_date TIMESTAMP NOT NULL,
  game_number INTEGER NOT NULL,
  week Text NOT NULL,
  split TEXT NOT NULL,
  in_game_hash TEXT NOT NULL,
  series_hash TEXT NOT NULL,
  realm TEXT NOT NULL,
  mongo_collection TEXT NOT NULL
);
