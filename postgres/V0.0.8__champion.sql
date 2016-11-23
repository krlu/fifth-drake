CREATE TABLE league.champion(
  id SERIAL PRIMARY KEY,
  name varchar(20) NOT NULL,
  key_name varchar(20) NOT NULL,
  riot_id TEXT NOT NULL
)
;
