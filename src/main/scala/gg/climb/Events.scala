package gg.climb

import gg.climb.analytics.EventStreamFactory
import gg.climb.lolobjects.esports.{Bot, Role, Support}
import gg.climb.lolobjects.game.state.PlayerState

import scala.concurrent.duration._

/**
  * Created by michael on 8/4/16.
  */
object Events {
  def main(args: Array[String]): Unit = {
    val time = getLaneSwap(1001790061)
    println("There should be no lane swap in P1-TSM-G2. Time of lane swap in seconds: " + time.toSeconds)
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
  def getLaneSwap(game: Int): Duration = {
    EventStreamFactory.gameStateStream(game)
      .filter(gs => {
        val notInBot = gs.blue.players.count(laneSwapRule) + gs.red.players.count(laneSwapRule)
        gs.blue.turrets == 0 && gs.red.turrets == 0 && gs.timestamp.gt(Duration(110, SECONDS)) && notInBot > 0
      })(0)._1
  }

  private def laneSwapRule(ps: PlayerState): Boolean = {
     !ps.location.inBotLane && !ps.location.inBase &&
       (Role.compare(ps.player.role, Bot()) || Role.compare(ps.player.role, Support()))
  }
}
