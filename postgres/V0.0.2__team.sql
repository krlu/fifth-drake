CREATE TABLE league.team (
  id SERIAL PRIMARY KEY,
  name VARCHAR(20),
  acronym VARCHAR(5),
  riot_id TEXT NOT NULL
)
;
