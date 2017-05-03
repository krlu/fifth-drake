CREATE TABLE league.auto_gen_tag (
  id SERIAL PRIMARY KEY,
  game_key TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  timestamp BIGINT NOT NULL
)
;
