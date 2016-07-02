CREATE TABLE league.ocr_game_stats(
  id SERIAL PRIMARY KEY,
  frame_id INTEGER NOT NULL,
  game_id TEXT NOT NULL,
  time_stamp TEXT NOT NULL,
  team_id INTEGER REFERENCES league.team(id), 
  kills TEXT NOT NULl, 
  turrets TEXT NOT NULL, 
  gold TEXT NOT NULL, 
  dragons TEXT NOT NULL, 
  side TEXT NOT NULL
)
;