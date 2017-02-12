package gg.climb.fifthdrake.dbhandling

import java.util.concurrent.TimeUnit

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.lolobjects.game.{Champion, GameData, InGameTeam, MetaData}
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import gg.climb.fifthdrake.{Game, Time}
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

  def deleteTag(id: InternalId[Tag]) = pdbh.deleteTag(id)
  def getTags(id: RiotId[Game]): Seq[Tag] = pdbh.getTagsForGame(id)
  def insertTag(tag: Tag): Unit = pdbh.insertTag(tag)

  def getPlayer(id: InternalId[Player]) = pdbh.getPlayer(id)
  def getChampion(championName: String): Option[Champion] = pdbh.getChampion(championName)

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

  def isUserAccountStored(userId: String): Boolean = pdbh.isUserAccountStored(userId)
  def isUserAuthorized(userId: String): Boolean = pdbh.isUserAuthorized(userId)
  def getPartialUserAccount(userId: String): (String, String, String) = pdbh.getPartialUserAccount(userId)
  def storeUserAccount(accessToken: String, refreshToken: String, payload: Payload): Unit = {
    Logger.info(s"attempting to store account information for user: ${payload.getSubject}")
    if (!isUserAccountStored(payload.getSubject)) {
      pdbh.storeUserAccount(
        payload.get("given_name").toString,
        payload.get("family_name").toString,
        payload.getSubject,
        payload.getEmail,
        authorized = false,
        accessToken,
        refreshToken,
        loggedIn = true
      )
      Logger.info("successfully stored user account")
    } else {
      Logger.info("user account already stored")
    }
  }

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
