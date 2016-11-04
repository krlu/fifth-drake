CREATE TABLE league.player_to_tag(
  id SERIAL PRIMARY KEY,
  tag_id INTEGER REFERENCES league.tag(id),
  player_id INTEGER REFERENCES league.player(id)
);
