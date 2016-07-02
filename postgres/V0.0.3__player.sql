CREATE TABLE league.player (
  id SERIAL PRIMARY KEY,
  first_name varchar(20) NOT NULL,
  last_name varchar(20) NOT NULL,
  riot_id TEXT NOT NULL
)
;
