package gg.climb.commons.dbhandling

import java.io.File
import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game._
import gg.climb.lolobjects.tagging.{Category, Tag}
import gg.climb.lolobjects.{InternalId, RiotId}
import scalikejdbc._

import scala.concurrent.duration.Duration


class PostgresDBHandler(host: String, port: Int, db : String,  user : String, password: String) {

  val url = "jdbc:postgresql://%s:%d/%s".format(host, port, db)

  ConnectionPool.singleton(url, user, password)

  /*********************************************************************************************************************
  ********************************************* CRUD methods for Tags **************************************************
  *********************************************************************************************************************/

  def getTagsForGame(gameKey: RiotId[Game]): List[Tag] = {
    val query = s"WHERE game_key = '${gameKey.id}'"
    val tagData: List[(Int, String, String, String, String, Long)] = DB readOnly { implicit session =>
      SQL(s"SELECT * FROM league.tag $query").map(rs => {
        (rs.int("id"), rs.string("game_key"), rs.string("title"),
          rs.string("description"), rs.string("category"), rs.long("timestamp"))
      }).list.apply()
    }
    return tagData.map(data => buildTag(data))
  }
  /**
    * @param data tuple of (internalId, riotGameId, title, description, category timestamp)
    * @return
    */
  private def buildTag(data: (Int, String, String, String, String, Long)): Tag = {
    val tagId = InternalId[Tag](data._1.toString)
    Tag(tagId, RiotId[Game](data._2), data._3, data._4, Category(data._5),
      Duration(data._6, TimeUnit.MILLISECONDS), getPlayersForTag(tagId))
  }
  private def getPlayersForTag(tagId : InternalId[Tag]) : Set[Player] = {
    val dbh = MongoDBHandler()
    getPlayerRiotIdsForTag(tagId).map(riotId => dbh.getPlayer(riotId))
  }
  private def getPlayerRiotIdsForTag(tagId: InternalId[Tag]) : Set[RiotId[Player]] = {
    val query = s"WHERE internal_tag_id=${tagId.id}"
    val tagIds: List[Int] = DB readOnly { implicit session =>
      SQL(s"SELECT player_riot_id FROM league.player_to_tag $query").map(rs => rs.int("player_riot_id")).list.apply()
    }
    return tagIds.map(id => RiotId[Player](id.toString)).toSet
  }

  def insertTag(tagData : ( String, String, String, String, Long, Set[RiotId[Player]])): Unit = {
    val query = s"'${tagData._1}', '${tagData._2}', '${tagData._3}', '${tagData._4}', '${tagData._5}'"
    DB localTx { implicit session => {
        val tag_id: Long = SQL(s"insert into league.tag (game_key, title, description, category, timestamp) " +
          s"values ($query)").updateAndReturnGeneratedKey().apply()
        tagData._6.foreach(id => {
          SQL(s"INSERT INTO league.player_to_tag (internal_tag_id, player_riot_id) " +
            s"values ($tag_id, ${id.id})").update.apply()
        })
      }
    }
  }

  def updateTag(tag: Tag): Unit = {
    DB localTx { implicit session => {
        SQL(s"UPDATE league.tag SET game_key=${tag.gameKey.id}, title='${tag.title}', " +
        s"description='${tag.description}', category='${tag.category.name}', timestamp=${tag.timestamp.toMillis}" +
        s"WHERE id=${tag.id.id}")
        .updateAndReturnGeneratedKey().apply()
        updatePlayersForTag(tag)
      }
    }
  }

  def deleteTag(tag: Tag): Unit = {
    getPlayerRiotIdsForTag(tag.id).foreach(riotId => deletePlayerToTag(riotId))
    DB localTx { implicit session => {
        SQL(s"DELETE FROM league.tag WHERE id=${tag.id.id}").update().apply()
      }
    }
  }

  /**
    * Deletes all players in table if that are no longer in the tag
    * Adds all players in tag that are not in table
    *
    * @param tag
    */
  private def updatePlayersForTag(tag: Tag): Unit ={
    val playerIds: Set[RiotId[Player]] = getPlayerRiotIdsForTag(tag.id)
    tag.players.foreach(player => {
      if(!playerIds.contains(player.riotId)){
        DB localTx { implicit session => {
            SQL(s"INSERT INTO league.player_to_tag (internal_tag_id, player_riot_id) " +
            s"values (${tag.id.id}, ${player.riotId.id})").update.apply()
          }
        }
      }
    })
    playerIds.foreach((id: RiotId[Player]) => {
      val ids: Set[RiotId[Player]] = tag.players.map(player => player.riotId)
      if(!ids.contains(id)) {
        deletePlayerToTag(id)
      }
    })
  }
  private def deletePlayerToTag(id : RiotId[Player]): Unit = {
    DB localTx { implicit session => {
        SQL(s"DELETE FROM league.player_to_tag WHERE player_riot_id=${id.id}").update().apply()
      }
    }
  }

  /*********************************************************************************************************************
  **************************************** Querying methods for Champion ***********************************************
  **********************************************************************************************************************/

  def getChampion(championName: String) : Champion = {
    val champId : List[Champion] = DB readOnly { implicit session =>
      SQL(s"SELECT * FROM league.champion Where name='$championName'").map(rs =>
        constructChampion(rs)
      ).list.apply()
    }
    return champId(0)
  }
  private def constructChampion(rs: WrappedResultSet): Champion = {
    val champId = InternalId[Champion](rs.int("id").toString)
    Champion(champId, RiotId[Champion](rs.int("riot_id").toString),
      rs.string("name"), getChampionStats(0), getChampionImage(champId))
  }
  private def getChampionStats(championId: Int): ChampionStats = {
    null
  }
  private def getChampionImage(championId: InternalId[Champion]): ChampionImage = {
    val x: Option[ChampionImage] = DB readOnly { implicit session => {
        SQL(s"SELECT * FROM league.champion_image WHERE champion_id=${championId.id}").map(rs =>{
          constructChampionImage(rs)
        })
      }.single.apply()
    }
    x.getOrElse(null)
  }
  private def constructChampionImage(rs: WrappedResultSet): ChampionImage = {
    val file = getChampionFile(rs.string("image_full"))
    ChampionImage(file, rs.int("x_position"), rs.int("y_position"), rs.int("width"), rs.int("height"),
      rs.string("sprite"),rs.string("image_full"), rs.string("image_group"))
  }
  private def getChampionFile(imageFull: String): File ={
    val filePath = "/"
    return new File(filePath + imageFull)
  }
  /*********************************************************************************************************************
  *************************************** Querying methods for Player Data *********************************************
  **********************************************************************************************************************/

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

object PostgresDBHandler{

  def apply(host: String, port: Int, dbName: String,
            user: String, password: String)=  new PostgresDBHandler(host, port, dbName, user, password)
}
