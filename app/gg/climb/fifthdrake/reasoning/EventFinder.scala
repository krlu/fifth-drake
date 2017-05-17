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
  * For automatically generating tags for events
  * NOTE: Does not currently support event periods, only time slices
  */
object EventFinder{

  type Group = Set[Player]

  //TODO: determine appropriate values, should parameterize
  val timeUnit = TimeUnit.MILLISECONDS
  var samplingRate = Duration(1000, timeUnit)
  val windowSize = 10
  val hpDeltaThreshold = 50
  val fightDistThreshold = 1000.0
  val skirmishThreshold = 3
  val teamfightThreshold = 6

  val sameLocationThreshold = 575
  val sameTimeThreshold = 10

  /**
    * Calculates all events over the course of an entire game
    * Currently each events trigger is rule based
    *
    * @param game - A game
    * @return ListEventStream[Duration,  Events at timeStamp]
    */
  private def getAllEventsForGame(game: Game): EventStream[Time, Set[GameEvent]] ={
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
      val fights = getFights(bluePlayers, redPlayers, timeStamp)
      val teamfights: Set[Teamfight] = getTeamFights(fights, timeStamp)

      val comparisons = teamfights.flatMap { fight =>
        val timesWithEvents = events.filter{case (timestamp, event) =>
          event.nonEmpty
        }
        if(timesWithEvents.isEmpty)
          Set(false)
        else
          timesWithEvents.last._2.map { event => fight.equals(event)}
      }
      if(!comparisons.contains(true))
        events += Tuple2(timeStamp, teamfights.asInstanceOf[Set[GameEvent]])
    }

    new ListEventStream[Time, Set[GameEvent]](events.toList)
  }

  /**
    * Option[PlayerState] is previous state (if there exists a previous state)
    * @param bluePlayers - blue team
    * @param redPlayers - red team
    * @param timestamp - in game time
    * @return
    */
  def getGank(bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
              redPlayers:  Map[Player, (Option[PlayerState], PlayerState)],
              fights: List[Fight], timestamp: Duration): Set[Gank]= {
    val allPlayers = bluePlayers ++ redPlayers
    getSkirmishes(fights, timestamp).flatMap { skirm =>
      val junglers = skirm.playersInvolved.filter(p => p.role.equals(Jungle))
      val junglerInLane = junglers.exists { jungler =>
        val states = allPlayers(jungler)
        states._1 match {
          case None => false
          case Some(prevState) => getLocationType(jungler, prevState, states._2).equals(InLane)
        }
      }
      junglerInLane match {
        case true => Some(Gank(skirm.players, skirm.location, timestamp))
        case false => None
      }
    }
  }

  private def getLocationType(player : Player, prevState : PlayerState, state: PlayerState) : LocationType = ???

  private def getTeamFights(fights: List[Fight], timestamp : Duration): Set[Teamfight]
    = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= teamfightThreshold)
      .map( p => Teamfight(p, getCentroid(fights.map(f => f.location).toSet), timestamp)).toSet

  private def getSkirmishes(fights: List[Fight], timestamp : Duration): Set[Skirmish]
    = mergeGroups(fights.map(f => f.playersInvolved))
      .filter(p => p.size >= skirmishThreshold && p.size < teamfightThreshold)
      .map( p => Skirmish(p, getCentroid(fights.map(f => f.location).toSet), timestamp)).toSet

  private def getFights(bluePlayers: Map[Player, (Option[PlayerState], PlayerState)],
                        redPlayers:  Map[Player, (Option[PlayerState], PlayerState)],
                        timestamp: Duration): List[Fight] = {
    for{
        redPlayer: (Player, (Option[PlayerState], PlayerState)) <- redPlayers
        bluePlayer: (Player, (Option[PlayerState], PlayerState)) <- bluePlayers
      } yield{getFight(bluePlayer, redPlayer, timestamp)}
    }.filter(f => f match {
      case None => false
      case _ => true
    }).map(f => f.get).toList

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

  /**
    * Merge sets of players with intersections by taking set unions
    *
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

  def generateFightTags(game: Game, gameKey : String, userId : UUID): Seq[Tag] = {
    val events = getAllEventsForGame(game)
    events.getAll.flatMap { case (time, eventSet) =>
      eventSet.flatMap{ (event: GameEvent) =>
        event match {
          case skirm : Skirmish =>
            val sec = time.toSeconds % 60 match {
              case x if x < 10 => "0" + time.toSeconds % 60
              case _ => "" + time.toSeconds % 60
            }
            Some(new Tag(
              new RiotId[Game](gameKey),
              s"Skirmish at ${time.toMinutes}:$sec",
              s"Skirmish involving ${skirm.playersInvolved.map(_.ign).mkString(", ")}",
              new Category("TeamFight"),
              time,
              skirm.playersInvolved,
              userId,
              List()
            )
            )
          case fightEvent: Teamfight =>
            val sec = time.toSeconds % 60 match {
              case x if x < 10 => "0" + time.toSeconds % 60
              case _ => "" + time.toSeconds % 60
            }
            Some(new Tag(
              new RiotId[Game](gameKey),
              s"Fight at ${time.toMinutes}:$sec",
              s"TeamFight involving ${fightEvent.playersInvolved.map(_.ign).mkString(", ")}",
              new Category("TeamFight"),
              time,
              fightEvent.playersInvolved,
              userId,
              List()
            )
            )
          case _ => None
        }
      }
    }
  }

  def generateObjectivesTags(gameData: Game,
                             timelineEvents: Seq[GameEvent],
                             gameKey : String, userId : UUID): Seq[Tag] = {
    Logger.info(s"Searching for Objectives events")
    val players = gameData._2.teams(Blue).playerStates ++ gameData._2.teams(Red).playerStates
    val participants = players.map{ case (player, states) =>
      new RiotId[(Side, Role)](states.apply(Duration.Zero).participantId.toString) -> player
    }
    timelineEvents.flatMap { event =>
      event match {
        case drag: DragonKill =>
          val sec = drag.timestamp.toSeconds % 60 match {
            case x if x < 10 => "0" + drag.timestamp.toSeconds % 60
            case _ => "" + drag.timestamp.toSeconds % 60
          }
          Some(new Tag(
            new RiotId[Game](gameKey),
            s"${drag.dragonType.name} killed at ${drag.timestamp.toMinutes}:$sec",
            s"${drag.dragonType.name} taken by ${participants(drag.killer).ign}",
            new Category("Objective"),
            drag.timestamp,
            Set(participants(drag.killer)),
            userId,
            List()
          ))
        case building: BuildingKill =>
          val sec = building.timestamp.toSeconds % 60 match {
            case x if x < 10 => "0" + building.timestamp.toSeconds % 60
            case _ => "" + building.timestamp.toSeconds % 60
          }
          val side = building.killer.id match {
            case "100" => Blue
            case "200" => Red
          }
          val description = building.buildingType match {
            case nex: NexusTurret => "Side nexus turret destroyed"
            case _ => s"${side.name} ${building.lane.name} ${building.buildingType.name} destroyed"
          }
          Some(new Tag(
            new RiotId[Game](gameKey),
            s"${building.buildingType.name} killed at ${building.timestamp.toMinutes}:$sec",
            description,
            new Category("Objective"),
            building.timestamp,
            Set(),
            userId,
            List()
          ))
        case _ => None
      }
    }
  }
}
