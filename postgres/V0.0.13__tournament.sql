CREATE TABLE league.tournament(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  riot_id TEXT,
  league_id INTEGER REFERENCES league.league(id),
  year INTEGER NOT NULL,
  title TEXT NOT NULL,
  split TEXT NOT NULL,
  phase TEXT NOT NULL
);
