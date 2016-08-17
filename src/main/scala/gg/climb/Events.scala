package gg.climb

import gg.climb.analytics.EventStreamFactory
import gg.climb.lolobjects.esports.{Bot, Player, Role, Support}
import gg.climb.lolobjects.game.LocationData
import gg.climb.lolobjects.game.state.{GameState, PlayerState, SideColor}
import gg.climb.ramenx.core.{EventStream, ListEventStream}

import scala.concurrent.duration._

/**
  * Created by michael on 8/4/16.
  */
object Events {
  def main(args: Array[String]): Unit = {
    val swap = laneswap(1001790061).scan(false, (_,_) => true)
  }

  /**
    * A gank has occurred if:
    * 1) player exits roaming
    * 2) skirmish occurs within 15 seconds
    */

  /**
    * A teamfight has occurred if:
    * 1) 8 - 10 participants
    * 2) pairwise distance between players is less than 2000 units
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */
  def teamfight(game: Int): EventStream[Duration, Set[Set[PlayerState]]] = {
    fight(game, 100, 100, 2000, 8, 10)
  }

  /**
    * A skirmish has occurred if:
    * 1) 2 - 7 participants
    * 2) pairwise distance less than 1500
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */
  def skirmish(game: Int): EventStream[Duration, Set[Set[PlayerState]]] = {
    fight(game, 100, 100, 1500, 2, 7)
  }

  private def fight(game: Int, hpLossPerSec: Double, mpLossPerSec: Double,
                    maxDist: Double, minPlayers: Int, maxPlayers: Int): EventStream[Duration, Set[Set[PlayerState]]] = {

    def bothSidesInFight(set: Set[PlayerState]): Boolean = {
      set.exists(ps => ps.sideColor.equals(SideColor.RED)) && set.exists(ps => ps.sideColor.equals(SideColor.BLUE))
    }

    val data = EventStreamFactory.gameStateStream(game)
    val windows = makeWindows(data, Duration(5, SECONDS))
      .map(w => {
        val es: EventStream[Duration, List[PlayerState]] = w.map(gs => gs.players)
        // All fights for a 5 second time window
        var fights = Set.empty[Set[PlayerState]]
        for (i <- 0 until es.first._2.size - 1) {
          var possibleFight = Set.empty[PlayerState]
          val psI = es.map(ps => ps(i))

          // Only consider p(i) if meets hp/mp conditions
          if (hpLossMet(psI, hpLossPerSec) && mpLossMet(psI, mpLossPerSec)) {
            possibleFight += psI.first._2
            // Set of other players that match distance
            val psISet = psI.map(ps => Set(ps))
            for (j <- i + 1 until es.first._2.size) {
              val psJ = es.map(ps => ps(j))
              // Compare p(i) with each p(j) for distance
              psISet.merge(psJ.map(ps => Set(ps)), (p1, p2) => p1.union(p2))
                .filter(set => distanceMet(set.head.location, set.last.location, maxDist))
                // union each
                .getAll.foreach(e => possibleFight.union(e._2))
            }

            // Add all possible fights to current time window
            if (possibleFight.size > 1 && bothSidesInFight(possibleFight)) {
              var found = false
              fights.foreach(fight => {
                if (fight.intersect(possibleFight).nonEmpty) {
                  fights += fight ++ possibleFight
                  fights -= fight
                  found = true
                }
              })

              if (!found) {
                fights += possibleFight
              }
            }
          }
        }

        fights.filter(set => set.size >= minPlayers && set.size <= maxPlayers)
      })
  }

  /**
    * A player is roaming if:
    * 1) not in any lane
    * 2) not in base
    */
  def roam(game: Int): EventStream[Duration, Set[PlayerState]] = {
    EventStreamFactory.gameStateStream(game)
      .filter(gameState => gameState.players.exists(ps => !ps.location.inLane && !ps.location.inBase)) // 1+ roaming
      .map(gameState => gameState.players.filter(ps => !ps.location.inLane && !ps.location.inBase)
                                         .toSet) // not in any lane or base
  }

  private def makeWindows[A](stream: EventStream[Duration, A], window: Duration): List[EventStream[Duration, A]] = {
    val all = List.empty[EventStream[Duration, A]]
    stream.getAll.foreach(ei => {
      if (ei._1 + window <= stream.last._1) {
        all :+ stream.getAll.filter(en => (en._1 >= ei._1) && (en._1 <= stream.last._1))
      }
    })
    all
  }

  private def hpLossMet(window: EventStream[Duration, PlayerState], minLossPerSecond: Double): Boolean = {
    val hpd = window.first._2.championState.hp - window.last._2.championState.hp
    val td = (window.last._1 - window.first._1).toSeconds
    (hpd > 0) && (hpd / td) >= minLossPerSecond
  }

  private def mpLossMet(window: EventStream[Duration, PlayerState], minLossPerSecond: Double): Boolean = {
    val mpd = window.first._2.championState.mp - window.last._2.championState.mp
    val td = (window.last._1 - window.first._1).toSeconds
    (mpd > 0) && (mpd / td) >= minLossPerSecond
  }

  private def distanceMet(a: LocationData, b: LocationData, max: Double): Boolean = {
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)) <= max
  }

  /**
    * A lane swap has occurred if:
    * 1) first turret has not fallen
    * 2) first minion wave has clashed (approx 1:50)
    * 3) Not bot/support vs bot/support in bot lane
    *
    * @param game The game ID
    * @return time at which a lane swap occurred
    */
  private def laneswap(game: Int): EventStream[Duration, Unit] = {
    EventStreamFactory.gameStateStream(game)
      .map(gs => {
        val notInBot = gs.blue.players.count(laneswapRule) + gs.red.players.count(laneswapRule)
        gs.blue.turrets == 0 && gs.red.turrets == 0 && gs.timestamp.gt(Duration(110, SECONDS)) && notInBot > 0
      })
  }

  private def laneswapRule(ps: PlayerState): Boolean = {
     !ps.location.inBotLane && !ps.location.inBase &&
       (Role.compare(ps.player.role, Bot()) || Role.compare(ps.player.role, Support()))
  }
}