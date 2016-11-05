package gg.climb.fifthdrake.reasoning
import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import gg.climb.ramenx.{EventStream, ListEventStream}

import scala.collection.mutable.ListBuffer
import scala.concurrent.duration.Duration

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
    * @param game - A game
    * @return ListEventStream[Duration,  Events at timeStamp]
    */
  def getAllEventsForGame(game: Game): EventStream[Time, Set[GameEvent]] ={
    val (metadata, gameData) = game

    val redPlayersOverTime = gameData.teams(Red).playerStates.map{
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, _-_)
    }
    val bluePlayersOverTime = gameData.teams(Blue).playerStates.map {
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, _-_)
    }
    val events = new ListBuffer[(Time, Set[GameEvent])]()
    val gameLength = metadata.gameDuration.toMillis.toInt
    val rate = samplingRate.toMillis.toInt

    for(t <- 0 until gameLength by rate) {
      val timeStamp = Duration(t, timeUnit)
      val redPlayers = redPlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val bluePlayers = bluePlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val fights = getFights(bluePlayers, redPlayers)
      val skirmishes: Set[GameEvent] = getSkirmishes(fights).map(FightEvent)
      val teamfights: Set[GameEvent] = getTeamFights(fights).map(FightEvent)
      events += Tuple2(timeStamp, skirmishes ++ teamfights)
    }
    new ListEventStream[Time, Set[GameEvent]](events.toList)
  }

  def getObjectiveTaken(side : Side, players: Map[Player, PlayerState]): Option[Objective] = None

  def getGank(fights: List[Option[Fight]]): Option[Set[Gank]]= None

  private def getTeamFights(fights: List[Fight]): Set[Teamfight] = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= teamfightThreshold)
      .map( p => Teamfight(p, getCentroid(fights.map(f => f.location).toSet))).toSet


  private def getSkirmishes(fights: List[Fight]): Set[Skirmish] = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= skirmishThreshold && p.size < teamfightThreshold)
      .map( p => Skirmish(p, getCentroid(fights.map(f => f.location).toSet))).toSet


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
    for {
      redPrevState <- redPlayer._2._1
      bluePrevState <- bluePlayer._2._1
      redState = redPlayer._2._2
      blueState = bluePlayer._2._2
      blueHpDelta = Math.abs(blueState.championState.hp - bluePrevState.championState.hp)
      redHpDelta = Math.abs(redState.championState.hp - redPrevState.championState.hp)
      if distance(blueState.location, redState.location) < fightDistThreshold &&
        (blueHpDelta > hpDeltaThreshold || redHpDelta > hpDeltaThreshold)
    } yield {
        new Fight(Set(bluePlayer._1, redPlayer._1),
                                    getCentroid(Set(bluePlayer._2._2.location,
                                                    redPlayer._2._2.location)))
    }
  }

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
        case Some(i) =>
          numMerges += 1
          mergedGroups.update(i, mergedGroups(i).union(pair))
        case None => mergedGroups += pair
      }
    }
    if(numMerges > 0) {
      mergeGroups(mergedGroups.toList)
    }
    else {
      mergedGroups.toList
    }
  }

  private def containsIntersection(sets : List[Group], u : Group): Option[Int] = {
    sets.indices.find(i => u.intersect(sets(i)).nonEmpty)
  }

  private def getCentroid(locations: Set[LocationData]): LocationData ={
    val x = locations.map(l => l.x).sum/locations.size
    val y = locations.map(l => l.y).sum/locations.size
    new LocationData(x,y,1.0)
  }

  private def distance(loc1: LocationData, loc2: LocationData): Double =
    Math.sqrt(Math.pow(loc1.x - loc2.x, 2) + Math.pow(loc1.y - loc2.y, 2))
}

