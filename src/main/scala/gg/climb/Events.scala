package gg.climb

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData
import gg.climb.lolobjects.game.state.PlayerState
import gg.climb.ramenx.core.{Behavior, EventStream}

import scala.concurrent.duration._
import scalaz.Monoid

/**
  * Created by michael on 8/4/16.
  */
object Events {

  /**
    * Represents a group of players involved in an event
    */
  type Group = Set[Player]

  implicit val m = new Monoid[Duration] {
    override def zero: Duration = Duration.Zero
    override def append(f1: Duration, f2: => Duration): Duration = f1 + f2
  }

  /**
    * A gank has occurred if:
    * 1) player exits roaming
    * 2) skirmish occurs within 10 seconds
    * 3) less than 3 turrets taken by either team
    */
  def gank(players: Behavior[Duration, Map[Player, PlayerState]],
           turrets: EventStream[Duration, (Int, Int)]): EventStream[Duration, Map[Group, Group]] = ???

  /**
    * A teamfight has occurred if:
    * 1) 8 - 10 participants
    * 2) pairwise distance between players is less than 2000 units
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */
  def teamfight(players: Behavior[Duration, Map[Player, PlayerState]]): EventStream[Duration, Set[Group]] = {
    fight(players, 100, 100, 2000, 8, 10)
  }

  /**
    * A skirmish has occurred if:
    * 1) 2 - 7 participants
    * 2) pairwise distance less than 1500
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */
  def skirmish(players: Behavior[Duration, Map[Player, PlayerState]]): EventStream[Duration, Set[Group]] = {
    fight(players, 100, 100, 1500, 2, 7)
  }

  private def fight(players: Behavior[Duration, Map[Player, PlayerState]],
                    hpLossThreshold: Double,
                    mpLossThreshold: Double,
                    maxDist: Double,
                    minPlayers: Int,
                    maxPlayers: Int): EventStream[Duration, Set[Group]] = {

    def hpLoss: Behavior[Duration, Map[Player, Double]] = players.withPrev(Duration(5, SECONDS), (t1, t2) => t1 - t2)
      .map({
        case (Some(x), y) => y.map({
          case (player, state) => player -> (x(player).championState.hp - state.championState.hp)
        })
        case (None, y) => y.map(x => x._1 -> 0.0)
      })

    def mpLoss = players.withPrev(Duration(5, SECONDS), (t1, t2) => t1 - t2)
      .map({
        case (Some(x), y) => y.map({
          case (player, state) => player -> (x(player).championState.mp - state.championState.mp)
        })
        case (None, y) => y.map(x => x._1 -> 0.0)
      })

    def partition(states: Map[Player, PlayerState]): Set[Group] = {

      def inFightRange(a: LocationData, b: LocationData, max: Double): Boolean = {
        math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)) <= max
      }

      var groups = states.mapValues(ps => Set(ps))

      groups.foreach({
        case (p1, g1) => groups.foreach({
          case (p2, g2) =>
            if (!p1.equals(p2)) {
              if (g1.exists(ps1 => g2.exists(ps2 => inFightRange(ps1.location, ps2.location, maxDist)))) {
                groups += p1 -> (g1 union g2)
                groups -= p2
              }
            }
        })
      })

      val x: ((Player, Set[PlayerState])) => Group = {case (player, group) => group.map(ps => ps.player)}
      groups.toSet.map(x)
    }

    def groups: Behavior[Duration, Set[Group]] = players.map(partition)

    def filterGroups: (((Map[Player, Double], Map[Player, Double]), Set[Group])) => Set[Group] = {
      case ((hpLoss, mpLoss), groups) =>
        groups.filter(g =>
          g.size >= minPlayers &&
          g.size <= maxPlayers &&
          g.exists(p => hpLoss(p) >= hpLossThreshold) &&
          g.exists(p => mpLoss(p) >=  mpLossThreshold))
    }

    hpLoss.zip(mpLoss)
          .zip(groups)
          .sampledBy(Duration.Zero, Duration(1, SECONDS), Duration.Inf)
          .map(filterGroups)
          .filter(_.nonEmpty)
  }

  /**
    * A player is roaming if:
    * 1) not in any lane
    * 2) not in base
    */
  def roam(players: Behavior[Duration, Map[Player, PlayerState]]): EventStream[Duration, Group] = {
    def isRoaming: (Player, PlayerState) => Boolean = {
      (p, ps) => !ps.location.inLane && !ps.location.inBase
    }

    def findRoamingPlayers: Map[Player, PlayerState] => Group = {
      states => states.filter({case (p, ps) => isRoaming(p, ps)})
                      .toSet
                      .map((x: (Player, PlayerState)) => x match {case (p, ps) => ps.player})
    }

    players.sampledBy(Duration.Zero, Duration(1, SECONDS), Duration.Inf)
           .map(findRoamingPlayers)
  }

  /**
    * Players associated with a dragon takedown
    *
    * @param takedown Stream of dragon takedown events
    * @param locations Behavior of all players during a game
    * @return
    */
  def dragon(takedown: EventStream[Duration, Unit],
             locations: Behavior[Duration, Map[Player, LocationData]]): EventStream[Duration, Group] = {
    Behavior.Whenever(locations)
            .<@(takedown)
            .map(players => players.filter(_._2.nearDragon).keySet)
  }

  /**
    * A lane swap has occurred if:
    * 1) Not bot/support vs bot/support in bot lane
    * 2) first minion wave has clashed (approx 1:50)
    * 3) first turret has not fallen
    */
}