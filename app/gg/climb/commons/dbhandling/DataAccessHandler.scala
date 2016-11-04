package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state._
import gg.climb.lolobjects.game.{GameData, InGameTeam, MetaData}
import gg.climb.ramenx.core.{Behavior, ListBehavior}

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
class DataAccessHandler(pdbh: PostgresDbHandler, mdbh: MongoDbHandler){

  type Game = (GameData, MetaData)

  def createGame(gameKey: RiotId[GameData]): Game ={

    val TIMEOUT = Duration(30, TimeUnit.SECONDS)

    val gameStates: Seq[GameState] = Await.result(mdbh.getCompleteGame(gameKey), TIMEOUT)
    val gid: MetaData = Await.result(mdbh.getGIDByRiotId(gameKey), TIMEOUT).get

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
    (new GameData(sideToTeam(redTeam, blueTeam)), gid)
  }

  private def behaviorForPlayers(playerStates: Seq[(Duration, Set[PlayerState])])
  : Map[Player, Behavior[Duration, PlayerState]] = separateStatesForPlayers(playerStates).map{ case (player, seq) =>
    val list = seq.toList.map{case (time, playerState) =>
      (time, constantFunction(playerState))
    }
    player -> new ListBehavior[Duration, PlayerState](list.head._2, list)
  }

  private def getBehaviorForTeams(teamStates: Seq[(Duration,TeamState)]) : Behavior[Duration, TeamState] = {
    val list = teamStates.map{case (time, teamState) =>(time, constantFunction(teamState))}.toList
    new ListBehavior[Duration, TeamState](list.head._2, list)
  }

  /**
    * Separates Sequence of combined playerStates into separate sequences
    *
    * @param playerStates - Seq[(Duration,Set[PlayerState])]
    * @return separatedPlayerStates - Map[Player, Seq]
    */
  private def separateStatesForPlayers(playerStates: Seq[(Duration,Set[PlayerState])])
  : Map[Player, Seq[(Duration, PlayerState)]] = {
    require(playerStates.nonEmpty)
    val firstSet: Set[PlayerState] = playerStates.head._2
    val setOfSeq = mutable.Map.empty[Player, Seq[(Duration,PlayerState)]]
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
  private def constantFunction(p: PlayerState): (Duration => PlayerState) = {d: Duration => p}
  private def constantFunction(t: TeamState): (Duration => TeamState) = {d: Duration => t}

}
