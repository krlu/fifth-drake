package gg.climb.fifthdrake.dbhandling

import java.util.UUID
import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.lolobjects.accounts._
import gg.climb.fifthdrake.lolobjects.esports._
import gg.climb.fifthdrake.lolobjects.game.{Champion, ChampionImage, ChampionStats, GameIdentifier}
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
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

  def getAllGameIdentifiers: Seq[GameIdentifier] = DB readOnly { implicit session =>
    sql"SELECT * FROM league.game_identifier"
      .map(rs =>
        new GameIdentifier(
          new InternalId[GameIdentifier](rs.string("id")),
          new RiotId[GameIdentifier](rs.string("game_key")),
          rs.string("blue_team"),
          rs.string("red_team"),
          getTourneyById(new InternalId[Tournament](rs.string("tournament_id"))),
          rs.int("week"),
          rs.int("game_number"))
      ).list().apply()
  }

  private def formatDate(s : String): DateTime = {
    val formatter = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss")
    formatter.parseDateTime(s)
  }

  private def getTourneyById(id : InternalId[Tournament]) : Tournament =  DB readOnly { implicit session =>
    sql"SELECT * FROM league.tournament WHERE id = ${id.id}::uuid"
      .map(rs => new Tournament(
        id, rs.int("year"), rs.string("split"),
        getLeagueById(new InternalId[League](rs.string("league_id"))),
        rs.string("phase")))
      .single().apply().orNull
  }

  private def getLeagueById(id : InternalId[League]): League = DB readOnly { implicit session =>
    sql"SELECT * FROM league.league WHERE id = ${id.id.toInt}"
      .map(rs => new League(id, rs.string("name"), new RiotId[League](rs.string("riot_id"))))
      .single().apply().orNull
  }

  def getTagById(tagId: InternalId[Tag]): Option[Tag] ={
    DB readOnly { implicit session =>
      sql"SELECT * FROM league.tag WHERE id = ${tagId.id.toInt}".map(rs => {
        val tagId = new InternalId[Tag](rs.int("id").toString)
        new Tag(
          Some(tagId),
          new RiotId[Game](rs.string("game_key")),
          rs.string("title"), rs.string("description"),
          new Category(rs.string("category")),
          Duration(rs.long("timestamp"), TimeUnit.MILLISECONDS),
          getPlayersForTag(tagId),
          UUID.fromString(rs.string("author")),
          buildUserGroupList(rs.array("authorized_groups"))
        )
      }).single().apply()
    }
  }

  def getTagsForGame(gameKey: RiotId[Game]): Seq[Tag] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM league.tag WHERE game_key = ${gameKey.id}".map(rs => {
        val tagId = new InternalId[Tag](rs.int("id").toString)
        new Tag(
          Some(tagId),
          new RiotId[Game](rs.string("game_key")),
          rs.string("title"), rs.string("description"),
          new Category(rs.string("category")),
          Duration(rs.long("timestamp"), TimeUnit.MILLISECONDS),
          getPlayersForTag(tagId),
          UUID.fromString(rs.string("author")),
          buildUserGroupList(rs.array("authorized_groups"))
        )
      }).list.apply()
    }
  }

  def getTagsWithAuthorizedGroupId(groupId: UUID): Seq[Tag] ={
    DB readOnly { implicit session =>
      sql"SELECT * FROM league.tag WHERE $groupId::uuid = ANY (authorized_groups)".map(rs => {
        val tagId = new InternalId[Tag](rs.int("id").toString)
        new Tag(
          Some(tagId),
          new RiotId[Game](rs.string("game_key")),
          rs.string("title"), rs.string("description"),
          new Category(rs.string("category")),
          Duration(rs.long("timestamp"), TimeUnit.MILLISECONDS),
          getPlayersForTag(tagId),
          UUID.fromString(rs.string("author")),
          buildUserGroupList(rs.array("authorized_groups"))
        )
      }).list.apply()
    }
  }

  def updateTagsAuthorizedGroups(newAuthorizedGroupIds: Seq[UUID], tagId: InternalId[Tag]): Int = {
    DB localTx { implicit session =>
      sql"""UPDATE league.tag
            SET authorized_groups = ${newAuthorizedGroupIds.mkString("{", ",", "}")}::uuid[]
            WHERE id=${tagId.id.toInt}"""
        .update()
        .apply()
    }
  }

  private def buildUserGroupMemberList(userGroupId: UUID): List[UUID] = {
    DB readOnly { implicit  session =>
      sql"SELECT users FROM account.user_group WHERE id=${userGroupId}::uuid"
        .map(rs => rs.array("users"))
        .list()
        .apply()
        .headOption
      match {
        case Some(users) => users.getArray.asInstanceOf[Array[UUID]].toList
        case None => List.empty
      }
    }
  }

  private def buildUserGroupList(authorizedGroups: java.sql.Array): List[UserGroup] = {
    authorizedGroups.getArray.asInstanceOf[Array[UUID]].map(uuid => {
      new UserGroup(uuid, buildUserGroupMemberList(uuid))
    }).toList
  }

  private def buildUserGroup(rs: WrappedResultSet): UserGroup = {
    new UserGroup(
      UUID.fromString(rs.string("id")),
      buildUserGroupMemberList(UUID.fromString(rs.string("id")))
    )
  }

  def findUserGroupByUserUuid(userUuid: UUID): Option[UserGroup] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM account.user_group WHERE ${userUuid}::uuid = ANY (users)"
        .map(buildUserGroup)
        .list()
        .apply()
        .headOption
    }
  }

  def findUserGroupByGroupUuid(userGroupUuid: UUID): Option[UserGroup] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM account.user_group WHERE id = ${userGroupUuid}::uuid"
        .map(buildUserGroup)
        .list()
        .apply()
        .headOption
    }
  }

  def insertUserGroup(user: User): Int = {
    DB localTx { implicit session =>
      sql"INSERT INTO account.user_group (users) VALUES (${"{" + user.uuid + "}"}::uuid[])"
        .update()
        .apply()
    }
  }

  def deleteUserGroup(userGroupId: UUID): Int = {
    DB localTx { implicit session =>
      sql"DELETE FROM account.user_group WHERE id = ${userGroupId}::uuid"
        .update()
        .apply()
    }
  }

  def updateUserGroup(userGroupId: UUID, users: List[UUID]): Int = {
    DB localTx { implicit session =>
      sql"""UPDATE account.user_group
            SET users = ${users.mkString("{", ",", "}")}::uuid[]
            WHERE id = ${userGroupId}::uuid"""
        .update()
        .apply()
    }
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

  def insertTag(tag: Tag): Long = {
    require(!tag.hasInternalId, s"Inserting tag titled Cannot insert Tag with InternalId, " +
      s"check that this Tag already exists in DB! Id is $tag")
    DB localTx { implicit session =>
      val groupUuids = tag.authorizedGroups.map(_.uuid).mkString("{", ",", "}")
      val tag_id: Long =
        sql"""insert into league.tag (game_key, title, description, category, timestamp, author, authorized_groups)
              values (${tag.gameKey.id},
                      ${tag.title},
                      ${tag.description},
                      ${tag.category.name},
                      ${tag.timestamp.toMillis},
                      ${tag.author}::uuid,
                      ${groupUuids}::uuid[])
             """.updateAndReturnGeneratedKey().apply()
      tag.players.foreach((id: Player) => {
        sql"""INSERT INTO league.player_to_tag (tag_id, player_id)
             values (${tag_id}, ${id.id.id.toInt})""".update.apply()
      })
      tag_id
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

  def deleteTag(tagId: InternalId[Tag]): Int = {
    getPlayerIdsForTag(tagId).foreach(riotId => deletePlayerToTag(riotId))
    DB localTx { implicit session =>
      sql"DELETE FROM league.tag WHERE id=${tagId.id.toInt}".update().apply()
    }
  }

  def getChampion(championName: String): Option[Champion] = DB readOnly {
    implicit session =>
      sql"SELECT * FROM league.champion where name=${championName} OR key_name=${championName}"
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

  def getPlayersByIgn(ign: String): Seq[Player] = {
    val ids = DB readOnly { implicit session =>
      sql"SELECT player_id FROM league.player_ign WHERE ign = $ign".map(rs => rs.string("player_id"))
        .list().apply()
    }
    ids.map(id => getPlayer(new InternalId[Player](id)))
  }

  def getPlayerByRiotId(riotId: RiotId[Player]): Player = {
    val id = getPlayerId(riotId)
    getPlayer(id)
  }

  private def getPlayerId(riotId: RiotId[Player]): InternalId[Player] = {
    val id = DB readOnly { implicit session =>
      sql"SELECT id FROM league.player WHERE riot_id = ${riotId.id}".map(rs => rs.string("id"))
        .single().apply().getOrElse("")
    }
    new InternalId[Player](id)
  }

  private def getPlayerRiotId(id : InternalId[Player]) : RiotId[Player] = {
    val riotIdVal = DB readOnly { implicit session =>
      sql"""
           SELECT riot_id
           FROM league.player
           WHERE id=${id.id.toInt}""".map(rs => rs.int("riot_id")).single().apply().getOrElse(-1)
    }
    new RiotId[Player](riotIdVal.toString)
  }

  def getTeamByAcronym(acronym: String, time: Option[DateTime] = None): Seq[Team] = {
    val ids = getTeamIdByAcronym(acronym)
    ids.map(id => getTeam(id, time))
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

  private def getTeamIdByAcronym(acronym: String): Seq[InternalId[Team]] = {
    val ids: List[String] = DB readOnly { implicit session =>
      sql"SELECT id FROM league.team WHERE acronym = ${acronym}"
        .map(rs => rs.string("id")).list().apply()
    }
    ids.map(id => new InternalId[Team](id))
  }

  def userExists(userId: String): Boolean = {
    DB readOnly { implicit session =>
      sql"SELECT id FROM account.user WHERE user_id = $userId"
        .map(rs => rs.string("id"))
        .list()
        .apply()
        .nonEmpty
    }
  }

  def isUserAuthorized(userId: String): Option[Boolean] = {
    DB readOnly { implicit session =>
      sql"SELECT authorized FROM account.user WHERE user_id = $userId"
        .map(rs => rs.boolean("authorized"))
        .list()
        .apply()
        .headOption
    }
  }

  private def buildUser(rs: WrappedResultSet): User = {
    new User(
      UUID.fromString(rs.string("id")),
      rs.string("first_name"),
      rs.string("last_name"),
      rs.string("user_id"),
      rs.string("email"),
      rs.boolean("authorized"),
      rs.string("access_token"),
      rs.string("refresh_token")
    )
  }

  def getUserByGoogleId(userId: String): Option[User] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM account.user WHERE user_id = $userId"
        .map(buildUser)
        .list()
        .apply()
        .headOption
    }
  }

  def getUserByUuid(uuid: UUID): Option[User] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM account.user WHERE id = ${uuid}::uuid"
        .map(buildUser)
        .list()
        .apply()
        .headOption
    }
  }

  def getUserByEmail(email: String): Option[User] = {
    DB readOnly { implicit session =>
      sql"SELECT * FROM account.user WHERE email = $email"
        .map(buildUser)
        .list()
        .apply()
        .headOption
    }
  }

  def storeUser(firstName: String,
                lastName: String,
                userId: String,
                email: String,
                authorized: Boolean,
                accessToken: String,
                refreshToken: String): Unit = {
    DB localTx { implicit session =>
      sql"""INSERT INTO account.user (
              first_name,
              last_name,
              user_id,
              email,
              authorized,
              access_token,
              refresh_token
            ) VALUES (
              $firstName,
              $lastName,
              $userId,
              $email,
              $authorized,
              $accessToken,
              $refreshToken
            )"""
        .update()
        .apply()
    }
  }

  def insertPermissionForUser(userId: UUID, groupID: UUID, permission: Permission): Unit ={
    DB localTx { implicit session =>
      sql"""INSERT INTO account.user_to_permission(
              user_id,
              group_id,
              permission
            ) VALUES (
              $userId,
              $groupID,
              ${permission.name}::account.permission_level
            )"""
        .update()
        .apply()
    }
  }

  def removePermissionForUser(userId: UUID, groupId: UUID): Unit ={
    DB localTx { implicit session =>
      sql"""DELETE FROM account.user_to_permission WHERE (
            user_id = $userId AND
            group_id = $groupId
          )"""
        .update()
        .apply()
    }
  }

  def getUserPermissionForGroup(userId: UUID, groupId : UUID): Option[Permission] = {
    DB readOnly { implicit session =>
      sql"""SELECT permission FROM account.user_to_permission WHERE (
           group_id = ${groupId} AND
           user_id = ${userId}
         )"""
        .map(rs => {
          val level = rs.string("permission") match {
            case "owner" => Owner
            case "admin" => Admin
            case "member" => Member
          }
          level
        }).single().apply()
    }
  }

  def getGroupPermissionsForUser(userId: UUID): Seq[(UUID, Permission)] = {
    DB readOnly { implicit session =>
      sql"""SELECT permission,group_id FROM account.user_to_permission WHERE (
           user_id = ${userId}
         )"""
        .map(rs => {
          val level: Permission = rs.string("permission") match {
            case "owner" => Owner
            case "admin" => Admin
            case "member" => Member
          }
          (UUID.fromString(rs.string("group_id")), level)
        }).list().apply()
    }
  }

  def getPermissionsForGroup(groupId : UUID): Seq[(UUID, Permission)] = {
    DB readOnly { implicit session =>
      sql"SELECT user_id, permission FROM account.user_to_permission WHERE group_id = ${groupId}"
        .map(rs => {
          val userId = UUID.fromString(rs.string("user_id"))
          val permission = rs.string("permission") match {
            case "owner" => Owner
            case "admin" => Admin
            case "member" => Member
          }
          (userId, permission)
        }).list().apply()
    }
  }

  def updateUserPermissionForGroup(userId: UUID, groupId: UUID, permission: Permission): Int = {
    DB localTx { implicit session =>
      sql"""UPDATE  account.user_to_permission
            SET permission = ${permission.name}::account.permission_level WHERE (
          group_id = ${groupId} AND
          user_id = ${userId}
        )"""
        .update().apply()
    }
  }
}

