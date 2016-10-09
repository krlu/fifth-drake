CREATE TABLE league.player_ign (
  id SERIAL PRIMARY KEY,
  player_id INTEGER REFERENCES league.player(id),
  adopted_date DATE NOT NULL,
  ign TEXT NOT NULL,
  region TEXT 
)
;
