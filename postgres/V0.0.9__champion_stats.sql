CREATE TABLE league.champion_stats (
  id SERIAL PRIMARY KEY,
  champion_id INTEGER REFERENCES league.champion(id),
  armor INTEGER NOT NULL,
  armor_per_level INTEGER NOT NULL,
  attack_range INTEGER NOT NULL,
  attack_speed_offset INTEGER NOT NULL,
  attack_speed_per_level INTEGER NOT NULL,
  attack_damage INTEGER NOT NULL,
  attack_damage_per_level INTEGER NOT NULL,
  crit INTEGER NOT NULL,
  crit_per_level INTEGER NOT NULL,
  hp INTEGER NOT NULL,
  hp_per_level INTEGER NOT NULL,
  hp_regen INTEGER NOT NULL,
  hp_regen_per_level INTEGER NOT NULL,
  move_speed INTEGER NOT NULL,
  mp INTEGER NOT NULL,
  mp_per_level INTEGER NOT NULL,
  mp_regen INTEGER NOT NULL,
  mp_regen_per_level INTEGER NOT NULL,
  spell_block INTEGER NOT NULL,
  spell_block_per_level INTEGER NOT NULL
)
;