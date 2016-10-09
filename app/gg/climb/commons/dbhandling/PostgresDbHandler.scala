package gg.climb.commons.dbhandling

import java.io.File
import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.esports.{Player, Role, Team}
import gg.climb.lolobjects.game._
import gg.climb.lolobjects.tagging.{Category, Tag}
import gg.climb.lolobjects.{InternalId, RiotId}
import org.joda.time.DateTime
import scalikejdbc._

import scala.concurrent.duration.Duration


class PostgresDbHandler(host: String, port: Int, db : String, user : String, password: String) {

  GlobalSettings.loggingSQLAndTime = LoggingSQLAndTimeSettings(
    enabled = false,
    singleLineMode = false,
    printUnprocessedStackTrace = false,
    stackTraceDepth= 15,
    logLevel = 'debug,
    warningEnabled = false,
    warningThresholdMillis = 3000L,
    warningLogLevel = 'warn
  )
  val url = "jdbc:postgresql://%s:%d/%s".format(host, port, db)

  ConnectionPool.singleton(url, user, password)

  /*********************************************************************************************************************
  ********************************************* CRUD methods for Tags **************************************************
  *********************************************************************************************************************/

  def getTagsForGame(gameKey: RiotId[Game]): Seq[Tag] = {
    val query = s"WHERE game_key = '${gameKey.id}'"
    val tagData: List[(Int, String, String, String, String, Long)] = DB readOnly { implicit session =>
      SQL(s"SELECT * FROM league.tag $query").map(rs => {
        (rs.int("id"), rs.string("game_key"), rs.string("title"),
          rs.string("description"), rs.string("category"), rs.long("timestamp"))
      }).list.apply()
    }
    tagData.map(data => buildTag(data))
  }
  /**
    * @param data tuple of (internalId, riotGameId, title, description, category timestamp)
    * @return
    */
  private def buildTag(data: (Int, String, String, String, String, Long)): Tag =  data match {
    case data : (Int, String, String, String, String, Long) =>
      val tagId = new InternalId[Tag](data._1.toString)
      new Tag(tagId, new RiotId[Game](data._2), data._3, data._4, new Category(data._5),
        Duration(data._6, TimeUnit.MILLISECONDS), getPlayersForTag(tagId))
    case _  => throw new IllegalArgumentException("")
  }
  private def getPlayersForTag(tagId : InternalId[Tag]) : Set[Player] = {
    val ids = getPlayerIdsForTag(tagId)
    ids.map(id => getPlayer(id))
  }

  private def getPlayerIdsForTag(tagId: InternalId[Tag]) : Set[InternalId[Player]] = {
    val query = s"WHERE tag_id=${tagId.id}"
    val tagIds: List[Int] = DB readOnly { implicit session =>
      SQL(s"SELECT player_id FROM league.player_to_tag $query").map(rs => rs.int("player_id")).list.apply()
    }
    tagIds.map(id => new InternalId[Player](id.toString)).toSet
  }

  def insertTag(tag : Tag): Unit = {
    require(!tag.hasInternalId, s"Inserting tag titled Cannot insert Tag with InternalId, " +
      s"check that this Tag already exists in DB! Id is $tag")
    val query = s"'${tag.gameKey.id}','${tag.title}','${tag.description}'," +
                s"'${tag.category.name}','${tag.timestamp.toMillis}'"
    DB localTx { implicit session => {
        val tag_id: Long = SQL(s"insert into league.tag (game_key, title, description, category, timestamp) " +
          s"values ($query)").updateAndReturnGeneratedKey().apply()
        tag.players.foreach((id: Player) => {
          SQL(s"INSERT INTO league.player_to_tag (tag_id, player_id) " +
            s"values ($tag_id, ${id.id.id})").update.apply()
        })
      }
    }
  }

  def updateTag(tag: Tag): Unit = {
    require(tag.hasInternalId, s"Tag '${tag.title}' is missing InternalId, check if Tag exists in DB!")
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
    getPlayerIdsForTag(tag.id).foreach(riotId => deletePlayerToTag(riotId))
    DB localTx { implicit session => {
        SQL(s"DELETE FROM league.tag WHERE id=${tag.id.id}").update().apply()
      }
    }
  }

  /**
    * Deletes all players in table if that are no longer in the tag
    * Adds all players in tag that are not in table
    *
    * @param tag The tag to update with
    */
  private def updatePlayersForTag(tag: Tag): Unit ={
    val playerIds: Set[InternalId[Player]] = getPlayerIdsForTag(tag.id)
    tag.players.foreach(player => {
      if(!playerIds.contains(player.id)){
        DB localTx { implicit session => {
            SQL(s"INSERT INTO league.player_to_tag (tag_id, player_id) " +
            s"values (${tag.id.id}, ${player.id.id})").update.apply()
          }
        }
      }
    })
    playerIds.foreach((id: InternalId[Player]) => {
      val ids: Set[InternalId[Player]] = tag.players.map(player => player.id)
      if(!ids.contains(id)) {
        deletePlayerToTag(id)
      }
    })
  }
  private def deletePlayerToTag(id : InternalId[Player]): Unit = {
    DB localTx { implicit session => {
        SQL(s"DELETE FROM league.player_to_tag WHERE player_id=${id.id}").update().apply()
      }
    }
  }

  /*********************************************************************************************************************
  **************************************** Querying methods for Champion ***********************************************
  **********************************************************************************************************************/

  def getChampion(championName: String) : Option[Champion] = {
    val champId  = DB readOnly { implicit session =>
      SQL(s"SELECT * FROM league.champion Where name='$championName'").map(rs =>
        constructChampion(rs)
      ).single().apply()
    }
    champId
  }

  private def constructChampion(rs: WrappedResultSet): Champion = {
    val champId = new InternalId[Champion](rs.string("id"))
    new Champion(champId, new RiotId[Champion](rs.int("riot_id").toString),
      rs.string("name"), getChampionStats(champId), getChampionImage(champId))
  }

  private def getChampionStats(championId: InternalId[Champion]): ChampionStats = {
    val x: Option[ChampionStats] = DB readOnly { implicit session => {
      SQL(s"SELECT * FROM league.champion_stats WHERE champion_id=${championId.id}").map(rs =>{
        constructChampionStats(rs)
      })
    }.single.apply()
    }
    x.orNull
  }
  private def constructChampionStats(rs : WrappedResultSet): ChampionStats = {
    new ChampionStats(rs.double("attack_range"),
      rs.double("move_speed"),
      rs.double("attack_speed_offset"),
      rs.double("attack_speed_per_level"),
      rs.double("attack_damage"),
      rs.double("attack_damage_per_level"),
      rs.double("hp"),
      rs.double("hp_per_level"),
      rs.double("hp_regen"),
      rs.double("hp_regen_per_level"),
      rs.double("mp"),
      rs.double("mp_per_level"),
      rs.double("mp_regen"),
      rs.double("mp_regen_per_level"),
      rs.double("armor"),
      rs.double("armor_per_level"),
      rs.double("spell_block"),
      rs.double("spell_block_per_level"),
      rs.double("crit"),
      rs.double("crit_per_level"))
  }

  private def getChampionImage(championId: InternalId[Champion]): ChampionImage = {
    val x: Option[ChampionImage] = DB readOnly { implicit session => {
        SQL(s"SELECT * FROM league.champion_image WHERE champion_id=${championId.id}").map(rs =>{
          constructChampionImage(rs)
        })
      }.single.apply()
    }
    x.orNull
  }
  private def constructChampionImage(rs: WrappedResultSet): ChampionImage = {
    val file = getChampionFile(rs.string("image_full"))
    new ChampionImage(file, rs.int("x_position"), rs.int("y_position"), rs.int("width"), rs.int("height"),
      rs.string("sprite"),rs.string("image_full"), rs.string("image_group"))
  }
  private def getChampionFile(imageFull: String): File ={
    val filePath = "/"
    new File(filePath + imageFull)
  }
  /*********************************************************************************************************************
  *************************************** Querying methods for Player Data *********************************************
  **********************************************************************************************************************/

  def getPlayerByRiotId(riotId: RiotId[Player]): Player = {
    val id: String = getPlayerId(riotId)
    val playerId = new InternalId[Player](id)
    getPlayer(playerId)
  }

  /**
    * Helper method for parsing player data
    *
    * @param playerId - InternalId[Player]
    * @param teamId - optional parameter, depends on whether the team id is known from a calling method
    * @return
    */
  def getPlayer(playerId: InternalId[Player], teamId: Option[String] = None): Player = {
    val id = playerId.id
    val ign = DB readOnly { implicit session =>
      SQL(s"SELECT ign FROM league.player_ign WHERE player_id = '$id'").map(rs => rs.string("ign")
      ).single().apply().getOrElse("")
    }
    val role: String = DB readOnly { implicit session =>
      SQL(s"SELECT role FROM league.player_role WHERE player_id = '$id'").map(rs => rs.string("role")
      ).single().apply().getOrElse("")
    }
    val team_id: String = teamId match{
      case None => DB readOnly { implicit session =>
        SQL(s"SELECT team_id FROM league.player_team WHERE player_id = '$id' order by end_date desc")
          .map(rs => rs.string("team_id")
          ).list().apply().head
      }
      case _ => teamId.get
    }
    new Player(playerId, ign, Role.interpret(role), team_id)
  }

  def getPlayerId(riotId: RiotId[Player]): String = {
    val id = DB readOnly { implicit session =>
      SQL(s"SELECT id FROM league.player WHERE riot_id = '${riotId.id}'").map(rs =>
        rs.string("id")
      ).single().apply()
    }
    id.orNull
  }
  /*********************************************************************************************************************
  *************************************** Querying methods for Team Data ***********************************************
  **********************************************************************************************************************/

  def getTeamByAcronym(acronym: String, time: Option[DateTime] = None): Team ={
    val id = getTeamIdByAcronym(acronym)
    getTeam(new InternalId[Team](id.toString), time)
  }

  def getTeam(teamId : InternalId[Team], time: Option[DateTime] = None): Team = {
    val id: String = teamId.id
    val (name, acronym) = DB readOnly { implicit session =>
      SQL(s"SELECT name,acronym FROM league.team WHERE id = '$id'").map(rs =>
        (rs.string("name"), rs.string("acronym"))
      ).single().apply().getOrElse("", "")
    }
    val players: Seq[Player] = DB readOnly { implicit session =>
      SQL(s"SELECT player_id FROM league.player_team WHERE team_id = '$id' and is_starter = 't' and " +
        s"start_date <= '${time.get}' and end_date > '${time.get}'")
        .map(rs => rs.string("player_id")).list().apply().map(p => getPlayer(new InternalId[Player](p), Some(id)))
    }
    new Team(teamId, name, acronym, players)
  }

  def getTeamIdByAcronym(acronym : String): String = {
    val id = DB readOnly { implicit session =>
      SQL(s"SELECT id FROM league.team WHERE acronym = '$acronym'").map(rs =>
        rs.string("id")
      ).single().apply()
    }
    id.orNull
  }
  def getTeamId(riotId: RiotId[Team]): String = {
    val id = DB readOnly { implicit session =>
      SQL(s"SELECT id FROM league.team WHERE riot_id = '${riotId.id}'").map(rs =>
        rs.string("id")
      ).single().apply()
    }
    id.orNull
  }
}

