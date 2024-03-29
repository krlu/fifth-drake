package gg.climb.fifthdrake.dbhandling

import java.util.UUID
import java.util.concurrent.TimeUnit

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import gg.climb.fifthdrake.lolobjects.accounts.{Permission, User, UserGroup}
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.lolobjects.game._
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import gg.climb.fifthdrake.reasoning.GameEvent
import gg.climb.fifthdrake.{Game, Time, Timeline}
import gg.climb.ramenx.{Behavior, ListBehavior}
import play.api.Logger

import scala.collection.mutable
import scala.concurrent.Await
import scala.concurrent.duration.Duration

/**
  * Data Access Wrapper that takes queries from Mongo and Postgres and transforms them as needed
  * Supports transformations into:
  *  - ListBehavior
  *
  * @param pdbh - PostgresDbHandler
  * @param mdbh - MongoDbHandler
  */
class DataAccessHandler(pdbh: PostgresDbHandler,mdbh: MongoDbHandler){

  def deleteTag(id: InternalId[Tag]): Int = pdbh.deleteTag(id)
  def getTags(id: RiotId[Game]): Seq[Tag] = pdbh.getTagsForGame(id)
  def getTagById(id: InternalId[Tag]): Option[Tag] = pdbh.getTagById(id)
  def insertTag(tag: Tag): InternalId[Tag] = pdbh.insertTag(tag)
  def insertAutoGenTag(tag: Tag) : InternalId[Tag] = pdbh.insertAutoGenTag(tag)
  def getAutoGenTagsForGame(gameKey : String) : Seq[Tag] = pdbh.getAutoGenTagsForGame(gameKey)
  def updateTag(tag: Tag): Option[InternalId[Tag]] = pdbh.updateTag(tag)
  def getTagsWithAuthorizedGroupId(groupId: UUID): Seq[Tag] = pdbh.getTagsWithAuthorizedGroupId(groupId)
  def updateTagsAuthorizedGroups(newAuthorizedGroupIds: Seq[UUID], tagId: InternalId[Tag]): Int =
    pdbh.updateTagsAuthorizedGroups(newAuthorizedGroupIds, tagId)

  def getPlayer(id: InternalId[Player]): Player = pdbh.getPlayer(id)
  def getPlayerByRiotId(id : RiotId[Player]) : Player = pdbh.getPlayerByRiotId(id)

  def getChampion(championName: String): Option[Champion] = pdbh.getChampion(championName)

  def getAllGameIdentifiers: Seq[GameIdentifier] = pdbh.getAllGameIdentifiers

  def getAllGames: Seq[MetaData] = {
    val TIMEOUT = Duration(30, TimeUnit.SECONDS)
    Await.result(mdbh.getAllGames, TIMEOUT)
  }

  def getTimelineForGame(gameKey: RiotId[Timeline]): Seq[GameEvent] = {
    val TIMEOUT = Duration(30, TimeUnit.SECONDS)
    Await.result(mdbh.getTimelineForGame(gameKey), TIMEOUT).orNull
  }

  def getGame(gameKey: RiotId[Game]): Option[Game] ={

    val TIMEOUT = Duration(30, TimeUnit.SECONDS)

    val gameStates: Seq[GameState] = Await.result(mdbh.getCompleteGame(gameKey), TIMEOUT)
    val metadata: Option[MetaData] = Await.result(mdbh.getGidByRiotId(gameKey), TIMEOUT)

    metadata.map(metadata => {
      val blueTeamStates = gameStates.map(state => (state.timestamp, state.blue._1))
      val bluePlayerStates = gameStates.map(state => (state.timestamp, state.blue._2))
      val redTeamStates = gameStates.map(state => (state.timestamp, state.red._1))
      val redPlayerStates = gameStates.map(state => (state.timestamp, state.red._2))

      val bluePlayerBehaviors = behaviorForPlayers(bluePlayerStates)
      val redPlayerBehaviors = behaviorForPlayers(redPlayerStates)
      val blueTeamBehaviors = getBehaviorForTeams(blueTeamStates)
      val redTeamBehaviors = getBehaviorForTeams(redTeamStates)

      val redTeam = new InGameTeam(redTeamBehaviors, redPlayerBehaviors)
      val blueTeam = new InGameTeam(blueTeamBehaviors, bluePlayerBehaviors)
      (metadata, new GameData(sideToTeam(redTeam, blueTeam)))
    })
  }

  def userExists(userId: String): Boolean = pdbh.userExists(userId)
  def isUserAuthorized(userId: String): Option[Boolean] = pdbh.isUserAuthorized(userId)
  def getUserByGoogleId(userId: String): Option[User] = pdbh.getUserByGoogleId(userId)
  def getUserByUuid(uuid: UUID): Option[User] = pdbh.getUserByUuid(uuid)
  def getUserByEmail(email: String): Option[User] = pdbh.getUserByEmail(email)
  def storeUser(accessToken: String, refreshToken: String, payload: Payload): Unit = {
    Logger.info(s"attempting to store user account information: ${payload.getSubject}")
    if (!userExists(payload.getSubject)) {
      pdbh.storeUser(
        payload.get("given_name").toString,
        payload.get("family_name").toString,
        payload.getSubject,
        payload.getEmail,
        authorized = false,
        accessToken,
        refreshToken
      )
      Logger.info(s"successfully stored user account: ${payload.getSubject}")
    } else {
      Logger.info(s"user account already stored: ${payload.getSubject}")
    }
  }

  def deleteUserGroup(userGroupId: UUID): Int = pdbh.deleteUserGroup(userGroupId)
  def createUserGroup(owner: User): Int = pdbh.insertUserGroup(owner)
  def updateUserGroup(userGroupId: UUID, users: List[UUID]): Int = pdbh.updateUserGroup(userGroupId, users)
  def getUserGroupByUser(user: User): Option[UserGroup] = pdbh.findUserGroupByUserUuid(user.uuid)
  def getUserGroupByUserUuid(uuid: UUID): Option[UserGroup] = pdbh.findUserGroupByUserUuid(uuid)
  def getUserGroupByUuid(userGroupUuid: UUID): Option[UserGroup] = pdbh.findUserGroupByGroupUuid(userGroupUuid)
  def insertPermissionForUser(userUuid: UUID, groupUuid: UUID, permission: Permission) =
    pdbh.insertPermissionForUser(userUuid, groupUuid, permission)
  def removePermissionForUser(userUuid: UUID, groupUuid: UUID) = pdbh.removePermissionForUser(userUuid, groupUuid)
  def getPermissionsForGroup(groupUuid: UUID) = pdbh.getPermissionsForGroup(groupUuid)
  def getUserPermissionForGroup(userId: UUID, groupId : UUID): Option[Permission] =
    pdbh.getUserPermissionForGroup(userId, groupId)
  def getGroupPermissionsForUser(userId: UUID): Seq[(UUID, Permission)] = pdbh.getGroupPermissionsForUser(userId)
  def updateUserPermissionForGroup(userUuid: UUID, groupUuid: UUID, permission: Permission) =
    pdbh.updateUserPermissionForGroup(userUuid, groupUuid, permission)

  private def behaviorForPlayers(playerStates: Seq[(Time, Set[PlayerState])])
  : Map[Player, Behavior[Time, PlayerState]] = separateStatesForPlayers(playerStates).map{ case (player, seq) =>
    val list = seq.toList.map{case (time, playerState) =>
      (time, Function.const(playerState) _)
    }
    player -> new ListBehavior[Time, PlayerState](list.head._2, list)
  }

  private def getBehaviorForTeams(teamStates: Seq[(Time,TeamState)]) : Behavior[Time, TeamState] = {
    val list = teamStates.map{case (time, teamState) =>(time, Function.const(teamState) _)}.toList
    new ListBehavior[Time, TeamState](list.head._2, list)
  }

  /**
    * Separates Sequence of combined playerStates into separate sequences
    *
    * @param playerStates - Seq[(Duration,Set[PlayerState])]
    * @return separatedPlayerStates - Map[Player, Seq]
    */
  private def separateStatesForPlayers(playerStates: Seq[(Time,Set[PlayerState])])
  : Map[Player, Seq[(Time, PlayerState)]] = {
    require(playerStates.nonEmpty)
    val firstSet: Set[PlayerState] = playerStates.head._2
    val setOfSeq = mutable.Map.empty[Player, Seq[(Time,PlayerState)]]
    firstSet.foreach(p => {
      setOfSeq += (pdbh.getPlayerByRiotId(p.id) -> playerStates.map{case (time, statesAtTime) =>
        (time, statesAtTime.find(state => state.id.equals(p.id)).get)
      })
    })
    setOfSeq.toMap
  }

  private def sideToTeam(redTeam: InGameTeam, blueTeam: InGameTeam): (Side => InGameTeam) = {
    case Blue => blueTeam
    case Red => redTeam
  }

}
