package gg.climb.fifthdrake.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.lolobjects.esports.{Player, Role, Team}
import gg.climb.fifthdrake.lolobjects.game._
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import org.joda.time.DateTime
import scalikejdbc._

import scala.concurrent.duration.Duration

//noinspection RedundantBlock
class PostgresDbHandler(host: String, port: Int, db: String, user: String, password: String) {

  val loggingStackTraceDepth = 15
  val warningThresholdMillis = 3000L
  GlobalSettings.loggingSQLAndTime =
    LoggingSQLAndTimeSettings(enabled = false,
                              singleLineMode = false,
                              printUnprocessedStackTrace = false,
                              stackTraceDepth = loggingStackTraceDepth,
                              logLevel = 'debug,
                              warningEnabled = false,
                              warningThresholdMillis = warningThresholdMillis,
                              warningLogLevel = 'warn
                             )
  val url = "jdbc:postgresql://%s:%d/%s".format(host, port, db)

  ConnectionPool.singleton(url, user, password)

  def getTagsForGame(gameKey: RiotId[Game]): Seq[Tag] = {
    val tagData: List[(Int, String, String, String, String, Long)] =
      DB readOnly { implicit session =>
        sql"SELECT * FROM league.tag WHERE game_key = ${gameKey.id}".map(rs => {
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
  private def buildTag(data: (Int, String, String, String, String, Long)): Tag = data match {
    case data: (Int, String, String, String, String, Long) =>
      val tagId = new InternalId[Tag](data._1.toString)
      new Tag(Some(tagId), new RiotId[Game](data._2), data._3, data._4, new Category(data._5),
              Duration(data._6, TimeUnit.MILLISECONDS), getPlayersForTag(tagId))
    case _ => throw new IllegalArgumentException("")
  }

  private def getPlayersForTag(tagId: InternalId[Tag]): Set[Player] = {
    val ids = getPlayerIdsForTag(tagId)
    ids.map(id => getPlayer(id))
  }

  /**
    * Helper method for parsing player data
    *
    * @param playerId - InternalId[Player]
    * @return
    */
  def getPlayer(playerId: InternalId[Player]): Player = {
    val id = playerId.id
    val ign = DB readOnly { implicit session =>
      sql"SELECT ign FROM league.player_ign WHERE player_id = ${id.toInt}"
        .map(rs => rs.string("ign"))
        .single()
        .apply()
        .getOrElse("")
    }
    val role: String = DB readOnly { implicit session =>
      sql"SELECT role FROM league.player_role WHERE player_id = ${id.toInt}"
        .map(rs => rs.string("role")
            ).single().apply().getOrElse("")
    }
    new Player(playerId, ign, Role.interpret(role), getPlayerRiotId(playerId))
  }

  def insertTag(tag: Tag): Unit = {
    require(!tag.hasInternalId, s"Inserting tag titled Cannot insert Tag with InternalId, " +
      s"check that this Tag already exists in DB! Id is $tag")
    DB localTx { implicit session => {
      val tag_id: Long =
        sql"""insert into league.tag (game_key, title, description, category, timestamp)
              values (${tag.gameKey.id},
                      ${tag.title},
                      ${tag.description},
                      ${tag.category.name},
                      ${tag.timestamp.toMillis})
             """.updateAndReturnGeneratedKey().apply()
      tag.players.foreach((id: Player) => {
        sql"""INSERT INTO league.player_to_tag (tag_id, player_id)
             values (${tag_id}, ${id.id.id.toInt})""".update.apply()
      })
    }
    }
  }

  def updateTag(tag: Tag): Unit = {
    require(tag.hasInternalId,
            s"Tag '${tag.title}' is missing InternalId, check if Tag exists in DB!")
    DB localTx { implicit session => {
      val where = tag.id.map(iid => sqls"WHERE id=${iid.id.toInt}").getOrElse("")
      sql"""UPDATE league.tag SET game_key=${tag.gameKey.id}, title=${tag.title},
          description=${tag.description}, category=${tag.category.name},
          timestamp=${tag.timestamp.toMillis} ${where}"""
        .updateAndReturnGeneratedKey().apply()
      updatePlayersForTag(tag)
    }
    }
  }

  /**
    * Deletes all players in table if that are no longer in the tag
    * Adds all players in tag that are not in table
    *
    * @param tag The tag to update with
    */
  private def updatePlayersForTag(tag: Tag): Unit = {
    for {
      id <- tag.id
    } yield {
      val playerIds: Set[InternalId[Player]] = getPlayerIdsForTag(id)
      tag.players.foreach(player => {
        if (!playerIds.contains(player.id)) {
          DB localTx { implicit session => {
            sql"""INSERT INTO league.player_to_tag (tag_id, player_id)
                  values (${id.id.toInt}, ${player.id.id.toInt})""".update.apply()
          }
          }
        }
      })
      playerIds.foreach((id: InternalId[Player]) => {
        val ids: Set[InternalId[Player]] = tag.players.map(player => player.id)
        if (!ids.contains(id)) {
          deletePlayerToTag(id)
        }
      })
    }
  }

  private def getPlayerIdsForTag(tagId: InternalId[Tag]): Set[InternalId[Player]] = {
    val tagIds: List[Int] = DB readOnly { implicit session =>
      sql"""SELECT player_id
            FROM league.player_to_tag
            WHERE tag_id=${tagId.id.toInt}""".map(rs => rs.int("player_id")).list
        .apply()
    }
    tagIds.map(id => new InternalId[Player](id.toString)).toSet
  }

  private def deletePlayerToTag(id: InternalId[Player]): Unit = {
    DB localTx { implicit session => {
      sql"DELETE FROM league.player_to_tag WHERE player_id=${id.id.toInt}".update().apply()
    }
    }
  }

  def deleteTag(tag: Tag): Unit = {
    for {
      id <- tag.id
    } yield {
      getPlayerIdsForTag(id).foreach(riotId => deletePlayerToTag(riotId))
      DB localTx { implicit session =>
        sql"DELETE FROM league.tag WHERE id=${id.id.toInt}".update().apply()
      }
    }
  }

  def getChampion(championName: String): Option[Champion] = DB readOnly {
    implicit session =>
      sql"SELECT * FROM league.champion where name=${championName}"
        .map(rs => constructChampion(rs)).single().apply()
  }

  private def constructChampion(rs: WrappedResultSet): Champion = {
    val champId = new InternalId[Champion](rs.string("id"))
    new Champion(champId, new RiotId[Champion](rs.int("riot_id").toString), rs.string("name"),
      rs.string("key_name"), getChampionStats(champId), getChampionImage(champId))
  }

  private def getChampionStats(championId: InternalId[Champion]): ChampionStats = {
    val x: Option[ChampionStats] = DB readOnly { implicit session => {
      sql"SELECT * FROM league.champion_stats WHERE champion_id=${championId.id.toInt}".map(rs => {
        constructChampionStats(rs)
      })
    }.single.apply()
    }
    x.orNull
  }

  private def constructChampionStats(rs: WrappedResultSet): ChampionStats = {
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
      sql"SELECT * FROM league.champion_image WHERE champion_id=${championId.id.toInt}".map(rs => {
        constructChampionImage(rs)
      })
    }.single.apply()
    }
    x.orNull
  }

  private def constructChampionImage(rs: WrappedResultSet): ChampionImage = {
    new ChampionImage(rs.int("x_position"),
                      rs.int("y_position"),
                      rs.int("width"),
                      rs.int("height"),
                      rs.string("sprite"),
                      rs.string("image_full"),
                      rs.string("image_group"))
  }

  def getPlayerByRiotId(riotId: RiotId[Player]): Player = {
    val id = getPlayerId(riotId)
    getPlayer(id)
  }

  def getPlayerId(riotId: RiotId[Player]): InternalId[Player] = {
    val id = DB readOnly { implicit session =>
      sql"SELECT id FROM league.player WHERE riot_id = ${riotId.id}".map(rs => rs.string("id"))
        .single().apply().getOrElse("")
    }
    new InternalId[Player](id)
  }

  def getPlayerRiotId(id : InternalId[Player]) : RiotId[Player] = {
    val riotIdVal = DB readOnly { implicit session =>
      sql"""
           SELECT riot_id
           FROM league.player
           WHERE id=${id.id.toInt}""".map(rs => rs.int("riot_id")).single().apply().getOrElse(-1)
    }
    new RiotId[Player](riotIdVal.toString)
  }

  def getTeamByAcronym(acronym: String, time: Option[DateTime] = None): Team = {
    val id = getTeamIdByAcronym(acronym)
    getTeam(new InternalId[Team](id.toString), time)
  }

  def getTeam(teamId: InternalId[Team], time: Option[DateTime] = None): Team = {
    val id: String = teamId.id
    val (name, acronym) = DB readOnly { implicit session =>
      sql"SELECT name,acronym FROM league.team WHERE id = ${id.toInt}"
        .map(rs => (rs.string("name"), rs.string("acronym"))).single().apply().getOrElse("", "")
    }
    val players: Seq[Player] = DB readOnly { implicit session =>
      sql"""SELECT player_id FROM league.player_team WHERE team_id = ${id.toInt} AND is_starter
           AND start_date <= ${time.get} AND end_date > ${time.get}"""
        .map(rs => rs.string("player_id")).list().apply()
        .map(p => getPlayer(new InternalId[Player](p)))
    }
    new Team(teamId, name, acronym, players)
  }

  def getTeamIdByAcronym(acronym: String): String = {
    val id = DB readOnly { implicit session =>
      sql"SELECT id FROM league.team WHERE acronym = ${acronym}"
        .map(rs => rs.string("id")).single().apply()
    }
    id.orNull
  }

  def getTeamId(riotId: RiotId[Team]): String = {
    val id = DB readOnly { implicit session =>
      sql"SELECT id FROM league.team WHERE riot_id = ${riotId.id.toInt}"
        .map(rs => rs.string("id")).single().apply()
    }
    id.orNull
  }
}

