import java.io.File

import gg.climb.lolobjects.game._
import scalikejdbc._

class PostgresDBHandler(host: String, port: Int, db : String,  user : String, password: String) {
	def foo(): Unit ={

	}

  val url = "jdbc:postgresql://%s:%d/%s".format(host, port, db)

  ConnectionPool.singleton(url, user, password)

	/*********************************************************************************************************************
  ********************************************* Insertions methods******************************************************
  **********************************************************************************************************************/


  //TODO: still needs implementing!!

/***********************************************************************************************************************
	*********************************************** Querying methods******************************************************
	**********************************************************************************************************************/


	def getChampion(championName: String) : Champion = {
	  val champId : List[Champion] = DB readOnly { implicit session =>
	    SQL(s"SELECT * FROM league.champion Where name='$championName'").map(rs =>
	      constructChampion(rs)
	    ).list.apply()
	  }
	  return champId(0)
	}
	private def constructChampion(rs: WrappedResultSet): Champion ={
		return null
	}
	private def getChampionStats(championId: Int): ChampionStats = {
		return null
	}
	private def getChampionImage(championId: Int): ChampionImage = {
		return null
	}
	private def getChampionFile(imageFull: String): File ={
		val filePath = "/"
		return new File(filePath + imageFull)
	}
  def getStaticPlayerDataByPlayer(playerName : String): List[(Int, String, Int, String)]= {
    val query = s"WHERE player='${playerName}'"
    return getStaticPlayerData(query)
  }
  def getStaticPlayerData(query : String): List[(Int, String, Int, String)] = {
    val game_keys: List[(Int, String, Int, String)]= DB readOnly { implicit session =>
      SQL(s"SELECT * FROM league.static_player_game_data $query").map(rs =>
        (rs.int("internal_game_id"),rs.string("champion"),rs.int("role"), rs.string("side_color"))
      ).list.apply()
    }
    return game_keys
  }
  /**
    * @param team1
    * @param team2
    * @return List[Int] of game_keys where team1 and team2 played
    */
  def getGameKeysByMatchup(team1 : String, team2 : String): List[Int] = {
    if (team1.equals(team2))
      throw new IllegalArgumentException("Matchup cannot be two of the same team!")
    val query = s"WHERE (team_1='$team1' and team_2='$team2') or (team_1='$team2' and team_2='$team1')"
    return getGameKeys(query)
  }
  /**
    * @param team
    * @return List[Int] of game_keys where team played
    */
  def getGameKeysByTeam(team : String): List[Int] = {
    val query = s"WHERE team_1='${team}' or team_2='${team}'"
    return getGameKeys(query)
  }

  def getGameKeys(query : String): List[Int] = {
    val game_keys: List[Int] = DB readOnly { implicit session =>
      SQL(s"SELECT game_key FROM league.game_identifier $query").map(rs => rs.int("game_key")).list.apply()
    }
    return game_keys
  }

  /**
    * @param team1
    * @param team2
    * @return List[Int] of internal_ids where team1 and team2 played
    */
  def getInternalGameIdByMatchup(team1 : String, team2 : String): List[Int] = {
    if(team1.equals(team2))
      throw new IllegalArgumentException("Matchup cannot be two of the same team!")
    val query = s"WHERE (team_1='$team1' and team_2='$team2') or (team_1='$team2' and team_2='$team1')"
    return getInternalIds(query)
  }
  /**
    * @param team
    * @return List[Int] of internal_ids where team played
    */
  def getInternalGameIdByTeam(team : String): List[Int] = {
    val query = s"WHERE team_1='$team' or team_2='$team'"
    return getInternalIds(query)
  }

  def getInternalIds(query : String ): List[Int] = {
    val ids: List[Int] = DB readOnly { implicit session =>
      SQL(s"SELECT id FROM league.game_identifier $query").map(rs => rs.int("id")).list.apply()
    }
    return ids
  }
}

object DBHandler{
  def main(args: Array[String]): Unit ={
    val dbh = new PostgresDBHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
    println(dbh.getChampion("RekSai"))
//    val idsForTeam = dbh.getInternalGameIdByTeam("TSM")
//    val idsForMatchup = dbh.getInternalGameIdByMatchup("TSM", "P1")
//    println(idsForTeam)
//    println(idsForMatchup)
//    println(dbh.getStaticPlayerDataByPlayer("Bjergsen"))
  }
}
