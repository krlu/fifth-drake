CREATE TABLE league.player_to_tag(
  id SERIAL PRIMARY KEY,
  internal_tag_id INTEGER REFERENCES league.tag(id),
  player_riot_id INTEGER NOT NULL
);
