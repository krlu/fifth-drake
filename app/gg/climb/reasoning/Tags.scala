package gg.climb.reasoning

import gg.climb.analytics.EventStreamFactory
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.Game
import gg.climb.lolobjects.game.state.PlayerState
import gg.climb.lolobjects.tagging.{Category, Tag}
import gg.climb.ramenx.core.{Behavior, EventStream}

import scala.concurrent.duration.Duration

/**
  * Created by michael on 8/28/16.
  */
object Tags {

  def forGame(game: RiotId[Game]): List[Tag] = {
    val players = formPlayers(game)
    val locations = players.map(_.mapValues(_.location))
    val dragonTakedowns = formDragonTakedowns(game)

    def combineLists: (List[Tag], List[Tag]) => List[Tag] = (a, b) => a ++ b

    val roams = Events.roam(players).mapWithTime({
      case (t, g) =>
        List(new Tag(game, "Roam", "One or more players roaming the map", new Category("Generated"), t, g))
    })

    val skirmishes = Events.skirmish(players).mapWithTime({
      case (t, sg) =>
        sg.map(g => new Tag(game, "Skirmish", "A brawl with 2-7 players", new Category("Generated"), t, g)).toList
    })

    val teamfights = Events.teamfight(players).mapWithTime({
      case (t, sg) =>
        sg.map(g => new Tag(game, "Teamfight", "A brawl with 8-10 players", new Category("Generated"), t, g)).toList
    })

    val dragons = Events.dragon(dragonTakedowns, locations).mapWithTime({
      case (t, g) =>
        List(new Tag(game, "Dragon", "Players involved in a dragon takedown", new Category("Generated"), t, g))
    })

    roams.merge(skirmishes, combineLists)
         .merge(teamfights, combineLists)
         .merge(dragons, combineLists)
         .getAll
         .flatMap(_._2)
  }

  private def formPlayers(game: RiotId[Game]): Behavior[Duration, Map[Player, PlayerState]] = {
    val states = EventStreamFactory.gameStateStream(game)
    states.stepper(states.first, states.last)
          .map(gs => gs.players.map(ps => ps.player -> ps)(collection.breakOut))
  }

  private def formDragonTakedowns(game: RiotId[Game]): EventStream[Duration, Unit] = {
    val states = EventStreamFactory.gameStateStream(game)
    var blueCount = 0
    var redCount = 0

    val blueDragons = states.filter(gs => {
      if (gs.blue.dragons > blueCount) {
        blueCount = gs.blue.dragons
        true
      } else {
        blueCount = gs.blue.dragons
        false
      }
    }).map(gs => ())

    val redDragons = states.filter(gs => {
      if (gs.red.dragons > redCount) {
        redCount = gs.red.dragons
        true
      } else {
        redCount = gs.red.dragons
        false
      }
    }).map(gs => ())

    blueDragons.merge(redDragons, (_,_) => ())
  }
}
