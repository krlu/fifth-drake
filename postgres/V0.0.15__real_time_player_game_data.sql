CREATE TABLE league.real_time_player_game_data(
  id SERIAL PRIMARY KEY NOT NULL,
  internal_game_id INTEGER REFERENCES league.game_identifier(id) NOT NULL,
  timestamp INTEGER NOT NULL,
  internal_player_id INTEGER REFERENCES league.static_player_game_data(id) NOT NULL,
  minion_kills INTEGER NOT NULL,
  current_gold INTEGER NOT NULL,
  total_gold INTEGER NOT NULL,
  health INTEGER NOT NULL,
  mana INTEGER NOT NULL,
  experience_points INTEGER NOT NULL,
  total_damage INTEGER NOT NULL,  
  x_position INTEGER NOT NULL,
  y_position INTEGER NOT NULL
);
