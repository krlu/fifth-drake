package gg.climb.reasoning

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state.LocationData


sealed trait GameEvent
case class FightEvent(fight: Fight) extends GameEvent
case class ObjectiveEvent(fight: Fight) extends GameEvent

sealed class Fight(val playersInvolved : Set[Player], val location : LocationData)
case class Gank(players : Set[Player], loc : LocationData) extends Fight(players, loc)
case class Teamfight(players : Set[Player], loc : LocationData) extends Fight(players, loc)
case class Skirmish(players : Set[Player], loc : LocationData) extends Fight(players, loc)

sealed class Objective(val location : LocationData)
case class Dragon(loc : LocationData) extends Objective(loc)
case class Baron(loc : LocationData) extends Objective(loc)
case class Turret(loc : LocationData) extends Objective(loc)
