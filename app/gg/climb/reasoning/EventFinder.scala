package gg.climb.reasoning

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state._
import gg.climb.lolobjects.game.{GameData, MetaData}
import gg.climb.ramenx.core.ListEventStream

import scala.collection.mutable.ListBuffer
import scala.concurrent.duration.Duration
import scalaz.Monoid

/**
  * NOTE: Does not currently support event periods, only time slices
  */
class EventFinder{

  type Group = Set[Player]

  //TODO: determine appropriate values, should parameterize
  val timeUnit = TimeUnit.MILLISECONDS
  var samplingRate = Duration(1000, timeUnit)
  val windowSize = 10
  val hpDeltaThreshold = 50
  val fightDistThreshold = 1000.0
  val skirmishThreshold = 3
  val teamfightThreshold = 8
  /**
    * Calculates all events over the course of an entire game
    * Currently each events trigger is rule based
    * @param gameData - all in game data as behaviors
    * @param metadata - metaData for given game
    * @return ListEventStream[Duration,  Events at timeStamp]
    */
  def getAllEventsForGame(gameData: GameData, metadata: MetaData): ListEventStream[Duration, Set[GameEvent]] ={

    val redPlayersOverTime = gameData.teams(Red).playerStates.map{
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, prev)(EventMonoid)
    }
    val bluePlayersOverTime = gameData.teams(Blue).playerStates.map{
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, prev)(EventMonoid)
    }
    val events = new ListBuffer[(Duration, Set[GameEvent])]()
    val gameLength = metadata.gameDuration.toMillis.toInt
    val rate = samplingRate.toMillis.toInt

    for(t <- 0 until gameLength by rate){
      val timeStamp = Duration(t, timeUnit)
      val redPlayers = redPlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val bluePlayers = bluePlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val fights = getFights(bluePlayers, redPlayers)
      events += Tuple2(timeStamp, getSkirmishes(fights) ++ getTeamFights(fights))
    }
    new ListEventStream[Duration, Set[GameEvent]](events.toList)
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// Event Rules Implementations ///////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////

  private def prev(curr: Duration, diff: Duration) = curr - diff

  def getObjectiveTaken(side : Side, players: Map[Player, PlayerState]): Option[Objective] = None

  def getGank(fights: List[Option[Fight]]): Option[Set[Gank]]= None

  private def getTeamFights(fights: List[Fight]): Set[Teamfight] = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= teamfightThreshold)
      .map( p => new Teamfight(p, getCentroid(fights.map(f => f.location).toSet))).toSet


  private def getSkirmishes(fights: List[Fight]): Set[Skirmish] = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= skirmishThreshold && p.size < teamfightThreshold)
      .map( p => new Skirmish(p, getCentroid(fights.map(f => f.location).toSet))).toSet


  private def getFights(bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
                              redPlayers:  Map[Player, (Option[PlayerState], PlayerState)]): List[Fight] = {
    for{
        redPlayer: (Player, (Option[PlayerState], PlayerState)) <- redPlayers
        bluePlayer: (Player, (Option[PlayerState], PlayerState)) <- bluePlayers
      } yield{getFight(bluePlayer, redPlayer)}
    }.filter(f => f match {
      case None => false
      case _ => true
    }).map(f => f.get).toList

  private def getFight(bluePlayer: (Player, (Option[PlayerState], PlayerState)),
               redPlayer: (Player, (Option[PlayerState], PlayerState))): Option[Fight] = {
    require(bluePlayer._2._2.sideColor.name != redPlayer._2._2.sideColor.name)
    if(!(redPlayer._2._1.isDefined && bluePlayer._2._1.isDefined))
      return None
    val redState  = redPlayer._2._2
    val blueState = bluePlayer._2._2
    val redPrevState  = redPlayer._2._1.get
    val bluePrevState = bluePlayer._2._1.get
    val blueHpDelta = Math.abs(blueState.championState.hp - bluePrevState.championState.hp)
    val redHpDelta  = Math.abs(redState.championState.hp - redPrevState.championState.hp)
    distance(blueState.location, redState.location) < fightDistThreshold &&
    (blueHpDelta > hpDeltaThreshold || redHpDelta > hpDeltaThreshold) match {
      case true => Some(new Fight(Set(bluePlayer._1, redPlayer._1),
        getCentroid(Set(bluePlayer._2._2.location, redPlayer._2._2.location))))
      case _ => None
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// Helper functions below //////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////

  /**
    * Merge sets of players with intersections by taking set unions
    * @param groups - List of player groups
    * @return groups
    */
  private def mergeGroups(groups: List[Group]): List[Group] = {
    val mergedGroups = new ListBuffer[Group]()
    var numMerges = 0
    for(pair <- groups){
      containsIntersection(mergedGroups.toList, pair) match {
        case i: Int if i >= 0 =>
          numMerges += 1
          mergedGroups.update(i, mergedGroups(i).union(pair))
        case _ => mergedGroups += pair
      }
    }
    if(numMerges > 0)
      return mergeGroups(mergedGroups.toList)
    mergedGroups.toList
  }
  private def containsIntersection(sets : List[Group], u : Group): Int = {
    for(i <- sets.indices) {
      val s = sets(i)
      if(u.intersect(s).nonEmpty)
        return i
    }
    -1
  }
  private def getCentroid(locations: Set[LocationData]): LocationData ={
    val x = locations.map(l => l.x).sum/locations.size
    val y = locations.map(l => l.y).sum/locations.size
    new LocationData(x,y,1.0)
  }
  private def distance(loc1: LocationData, loc2: LocationData): Double =
    Math.sqrt(Math.pow(loc1.x - loc2.x, 2) + Math.pow(loc1.y - loc2.y, 2))
}

