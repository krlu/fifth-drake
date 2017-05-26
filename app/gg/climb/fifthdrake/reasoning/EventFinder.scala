package gg.climb.fifthdrake.reasoning
import java.util.UUID
import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake._
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.{Jungle, Player, Role}
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.ramenx.{EventStream, ListEventStream}
import play.api.Logger

import scala.collection.mutable.ListBuffer
import scala.concurrent.duration.Duration

/**
  * Calculates all events over the course of an entire game
  * Currently events are determined via a rule based system
  * Then Automatically generates tags for each event
  * Objectives are taken directly from timeline json
  */
object EventFinder{

  type Group = Set[Player]

  private val timeUnit = TimeUnit.MILLISECONDS
  private val samplingRate = Duration(1000, timeUnit)
  private val windowSize = 10
  private val hpDeltaThreshold = 50
  private val fightDistThreshold = 1000.0
  private val skirmishThreshold = 3
  private val teamfightThreshold = 6
  private val sameLocationThreshold = 4000
  private val sameTimeThreshold = 60
  private val gankTimeThreshold = 900

  private def getAllEventsForGame(game: Game): EventStream[Time, Set[GameEvent]] ={
    val (metadata, gameData) = game

    val redPlayersOverTime = gameData.teams(Red).playerStates.map{
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, _-_)
    }
    val bluePlayersOverTime = gameData.teams(Blue).playerStates.map {
      case(p , ps) => p -> ps.withPrev(windowSize * samplingRate, _-_)
    }

    val gameLength = metadata.gameDuration.toMillis.toInt
    val rate = samplingRate.toMillis.toInt
    var prevEvents =  Set.empty[GameEvent]

    val events = (0 until gameLength by rate).map{ t =>
      val timeStamp = Duration(t, timeUnit)
      val redPlayers = redPlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val bluePlayers = bluePlayersOverTime.map{case (p, ps) => p -> ps(timeStamp)}
      val fights = getUniqueFights(prevEvents, bluePlayers, redPlayers, timeStamp)
      val teamfights: Set[Teamfight] = getTeamFights(fights, timeStamp)
      val ganks : Set[Gank] = getGank(bluePlayers, redPlayers, fights, timeStamp)
      val allFights = teamfights.asInstanceOf[Set[GameEvent]] ++ ganks.asInstanceOf[Set[GameEvent]]
      if(allFights.nonEmpty){
        prevEvents = allFights
      }
      (timeStamp, allFights)
    }.toList

    new ListEventStream[Time, Set[GameEvent]](events)
  }

  private def getGank(bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
              redPlayers:  Map[Player, (Option[PlayerState], PlayerState)],
              fights: Set[Fight], timestamp: Duration): Set[Gank]= {
    val allPlayers = bluePlayers ++ redPlayers
    getSkirmishes(fights, timestamp).flatMap { skirm =>
      timestamp.toSeconds match {
        case x if x > gankTimeThreshold => None
        case _ =>
          val junglers = skirm.playersInvolved.filter(p => p.role.equals(Jungle))
          val junglerInLane = junglers.exists { jungler =>
            val (prevSate, currState) = allPlayers(jungler)
            prevSate match {
              case None => false
              case Some(prevState) => MapRegion.getLocationType(jungler, prevState, currState).equals(InLane)
            }
          }
          junglerInLane match {
            case true => Some(Gank(skirm.players, skirm.location, timestamp))
            case false => None
          }
      }
    }
  }
  private def getTeamFights(fights: Set[Fight], timestamp : Duration): Set[Teamfight]
    = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(group => group.size >= teamfightThreshold)
      .map( group => Teamfight(group, getCentroid(fights.map(f => f.location)), timestamp))

  private def getSkirmishes(fights: Set[Fight], timestamp : Duration): Set[Skirmish]
    = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(group => group.size >= skirmishThreshold && group.size < teamfightThreshold)
      .map( group => Skirmish(group, getCentroid(fights.map(f => f.location)), timestamp))

  private def getUniqueFights(prevEvents : Set[GameEvent],
                              bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
                              redPlayers:  Map[Player, (Option[PlayerState], PlayerState)],
                              timestamp: Duration): Set[Fight] = {
    val fights = getFights(bluePlayers, redPlayers, timestamp)
    fights.flatMap{ fight =>
      prevEvents.isEmpty match {
        case true => Some(fight)
        case false =>
          prevEvents.exists {
            case prevFight: Fight => sameFight(prevFight, fight)
            case _ => false
          } match {
            case true => None
            case false => Some(fight)
          }
      }
    }
  }
  private def getFights(bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
                        redPlayers:  Map[Player, (Option[PlayerState], PlayerState)],
                        timestamp: Duration): Set[Fight] = {
    for{
        redPlayer: (Player, (Option[PlayerState], PlayerState)) <- redPlayers
        bluePlayer: (Player, (Option[PlayerState], PlayerState)) <- bluePlayers
        fight <- getFight(bluePlayer, redPlayer, timestamp)
      } yield fight
    }.toSet

  private def getFight(bluePlayer: (Player, (Option[PlayerState], PlayerState)),
                       redPlayer: (Player, (Option[PlayerState], PlayerState)),
                       timestamp : Duration) : Option[Fight] = {
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
          getCentroid(Set(bluePlayer._2._2.location, redPlayer._2._2.location)), timestamp)
    }
  }
  private def sameFight(e1: Fight, e2: Fight): Boolean =
    sameLocation(e1, e2) && Math.abs(e1.timestamp.toSeconds - e2.timestamp.toSeconds) < sameTimeThreshold

  private def sameLocation(e1: Fight, e2: Fight): Boolean =
    distance(e1.location, e2.location) < sameLocationThreshold

  private def mergeGroups(groups: Set[Group]): Set[Group] = {
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
      mergeGroups(mergedGroups.toSet)
    }
    else {
      mergedGroups.toSet
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

  def generateFightTags(game: Game, gameKey : String, userId : UUID): Seq[Tag] = {
    val events = getAllEventsForGame(game)
    events.getAll.flatMap { case (time, eventSet) =>
      eventSet.flatMap{ (event: GameEvent) =>
        val timeStr = secondsFormat(time)
        val eventData = event match {
          case skirm : Skirmish =>
            Some(s"Skirmish at $timeStr", skirm.playersInvolved, new Category("TeamFight"))
          case fightEvent: Teamfight =>
            Some(s"Fight at $timeStr", fightEvent.playersInvolved, new Category("TeamFight"))
          case gank : Gank =>
            Some(s"Gank at $timeStr", gank.playersInvolved, new Category("TeamFight"))
          case _ => None
        }
        eventData match {
          case Some((title, players, category)) =>
            Some(new Tag( new RiotId[Game](gameKey),
              title, s"$title involving ${players.map(_.ign).mkString(", ")}",
              category, time, players, userId, List()))
          case None => None
        }
      }
    }
  }

  def generateObjectivesTags(gameData: Game, timelineEvents: Seq[GameEvent],
                             gameKey : String, userId : UUID): Seq[Tag] = {
    Logger.info(s"Searching for Objectives events")
    val allPlayers = gameData._2.teams(Blue).playerStates ++ gameData._2.teams(Red).playerStates
    val participants = allPlayers.map{ case (player, states) =>
      new RiotId[(Side, Role)](states.apply(Duration.Zero).participantId.toString) -> player
    }
    timelineEvents.flatMap { event =>
      val eventData = event match {
        case drag: DragonKill =>
          val timeStr = secondsFormat(drag.timestamp)
          Some(s"${drag.dragonType.name} killed at $timeStr",
            s"${drag.dragonType.name} taken by ${participants(drag.killer).ign}",
            new Category("Objective"),
            drag.timestamp,
            Set(participants(drag.killer)))
        case building: BuildingKill =>
          val timeStr = secondsFormat(building.timestamp)
          val side = building.killer.id match {
            case "100" => Blue
            case "200" => Red
          }
          val description = building.buildingType match {
            case nex: NexusTurret => s"${side.name} nexus turret destroyed"
            case _ => s"${side.name} ${building.lane.name} ${building.buildingType.name} destroyed"
          }
          Some(s"${building.buildingType.name} destroyed at $timeStr",
            description,
            new Category("Objective"),
            building.timestamp,
            Set.empty[Player])
        case _ => None
      }
      eventData match {
        case Some((title, desc, category, time, playersInvolved)) =>
          Some(new Tag(new RiotId[Game](gameKey), title, desc, category, time, playersInvolved, userId, List()))
        case None => None
      }
    }
  }
  private def secondsFormat(time : Time): String = {
    val sec = time.toSeconds
    val secStr = sec % 60 match {
      case x if x < 10 => "0" + sec % 60
      case _ => sec % 60
    }
    s"${time.toMinutes}:$secStr"
  }
}
