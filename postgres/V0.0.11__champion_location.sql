CREATE TABLE league.champion_location(
  id SERIAL PRIMARY KEY,
  frame_id INTEGER NOT NULL,
  game_id TEXT NOT NULL,
  champion_name TEXT NOT NULL,
  match_coeff REAL NOT NULL,
  x_position REAL NOT NULL, 
  y_position REAL NOT NULL
)
;