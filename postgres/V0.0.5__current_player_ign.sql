CREATE VIEW league.current_player_ign AS
  SELECT t1.*
  FROM league.player_ign AS t1
  NATURAL JOIN (
    SELECT
      player_id,
      MAX(adopted_date) AS adopted_date
    FROM league.player_ign
    GROUP BY 1
  ) AS t2
;
