CREATE TABLE league.tournament(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  riot_id TEXT,
  year INTEGER NOT NULL,
  region TEXT NOT NULL,
  sub_season TEXT NOT NULL
);
