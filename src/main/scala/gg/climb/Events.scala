package gg.climb

import gg.climb.analytics.EventStreamFactory
import gg.climb.lolobjects.esports.{Bot, Role, Support}
import gg.climb.lolobjects.game.state.PlayerState
import gg.climb.ramenx.core.EventStream

import scala.concurrent.duration._

/**
  * Created by michael on 8/4/16.
  */
object Events {
  def main(args: Array[String]): Unit = {
    val swap = laneswap(1001790061).scan[Boolean](false, (_,_) => true)
  }

  /**
    * A gank has occurred if:
    * 1) player exits roaming
    * 2) skirmish occurs within 15 seconds
    */

  /**
    * A teamfight has occurred if:
    * 1) pairwise distance between players is less than 2000 units
    * 2) min 4v4
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */

  /**
    * A skirmish has occurred if:
    * 1) min 1v1
    * 2) pairwise distance less than 1500
    * 3) hp loss above 100 per second
    * 4) mp usage above 100 per second
    */

  /**
    * A player is roaming if:
    * 1) not in any lane
    * 2) not in base
    */

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
      .map[Unit](gs => {
        val notInBot = gs.blue.players.count(laneswapRule) + gs.red.players.count(laneswapRule)
        gs.blue.turrets == 0 && gs.red.turrets == 0 && gs.timestamp.gt(Duration(110, SECONDS)) && notInBot > 0
      })
  }

  private def laneswapRule(ps: PlayerState): Boolean = {
     !ps.location.inBotLane && !ps.location.inBase &&
       (Role.compare(ps.player.role, Bot()) || Role.compare(ps.player.role, Support()))
  }
}