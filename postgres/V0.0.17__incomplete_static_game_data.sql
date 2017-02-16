CREATE TABLE league.incomplete_static_player_game_data(
  id SERIAL PRIMARY KEY NOT NULL,
  internal_game_id UUID REFERENCES league.game_identifier(id) NOT NULL,
  player TEXT NOT NULL,
  champion TEXT NOT NULL,
  role INTEGER NOT NULL,
  side_color TEXT NOT NULL,
  team_acronym TEXT NOT NULL
);
