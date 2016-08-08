package gg.climb

import gg.climb.analytics.EventStreamFactory
import gg.climb.lolobjects.esports.Player
import gg.climb.ramenx.core.EventStream

import scala.concurrent.duration.Duration

/**
  * Created by michael on 8/7/16.
  */
object Element {
  /**
    * HP behavior of all players for the entire duration of a game
    *
    * @param game The game id
    * @return
    */
  def hp(game: Int): Map[Player, EventStream[Duration, Double]] = {
    val stream = EventStreamFactory.gameStateStream(game).map(gs => gs.teams.flatMap(ts => ts.players))
    val players = stream.first().map(ps => ps.player)

    players.map(p => {
      val hp = stream.map(list => list.find(ps => ps.player.equals(p)).get.championState.hp)
      (p, hp)
    }).toMap
  }

  /**
    * MP behavior of all players for the entire duration of a game
    *
    * @param game The game id
    * @return
    */
  def mp(game: Int): Map[Player, EventStream[Duration, Double]] = {
    val stream = EventStreamFactory.gameStateStream(game).map(gs => gs.teams.flatMap(ts => ts.players))
    val players = stream.first().map(ps => ps.player)

    players.map(p => {
      val mp = stream.map(list => list.find(ps => ps.player.equals(p)).get.championState.mp)
      (p, mp)
    }).toMap
  }

  /**
    * XP behavior of all players for the entire duration of a game
    *
    * @param game The game id
    * @return
    */
  def xp(game: Int): Map[Player, EventStream[Duration, Double]] = {
    val stream = EventStreamFactory.gameStateStream(game).map(gs => gs.teams.flatMap(ts => ts.players))
    val players = stream.first().map(ps => ps.player)

    players.map(p => {
      val xp = stream.map(list => list.find(ps => ps.player.equals(p)).get.championState.xp)
      (p, xp)
    }).toMap
  }
}
