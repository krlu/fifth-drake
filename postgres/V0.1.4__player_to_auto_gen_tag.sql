CREATE TABLE league.player_to_auto_gen_tag (
  id SERIAL PRIMARY KEY,
  auto_gen_tag_id INTEGER REFERENCES league.auto_gen_tag(id),
  player_id INTEGER REFERENCES league.player(id)
)
;
