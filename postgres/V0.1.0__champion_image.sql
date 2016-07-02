CREATE TABLE league.champion_image(
  id SERIAL PRIMARY KEY,
  champion_id INTEGER REFERENCES league.champion(id),
  image_full TEXT NOT NULL, 
  image_group TEXT NOT NULL,
  sprite TEXT NOT NULL,
  x_position INTEGER NOT NULL,
  y_position INTEGER NOT NULL, 
  width INTEGER NOT NULL,
  height INTEGER NOT NULL
)
;