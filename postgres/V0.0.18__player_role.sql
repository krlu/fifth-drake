CREATE TABLE league.player_role(
  id SERIAL PRIMARY KEY,
  player_id INTEGER REFERENCES league.player(id),
  role TEXT NOT NULL
);
