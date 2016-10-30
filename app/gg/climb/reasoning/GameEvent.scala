package gg.climb.reasoning

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state.LocationData


sealed trait GameEvent{
  val name: String = "GameEvent"
}

sealed class Fight(val playersInvolved : Set[Player], val location : LocationData) extends GameEvent{
  override val name: String = "Fight"
  def equals(other: Fight): Boolean = this.name == other.name && dist(other) < 10

  def dist(other: Fight) = distance(this.location, other.location)

  private def distance(loc1: LocationData, loc2: LocationData): Double =
    Math.sqrt(Math.pow(loc1.x - loc2.x, 2) + Math.pow(loc1.y - loc2.y, 2))
}
case class Gank(players : Set[Player], loc : LocationData) extends Fight(players, loc){
  override val name: String = "Gank"
}
case class Teamfight(players : Set[Player], loc : LocationData) extends Fight(players, loc){
  override val name: String = "Teamfight"
}
case class Skirmish(players : Set[Player], loc : LocationData) extends Fight(players, loc){
  override val name: String = "Skirmish"
}

sealed class Objective(val location : LocationData) extends GameEvent{
  override val name: String = "Objective"
  def equals(other: Objective): Boolean = this.name == other.name
}
case class Dragon(loc : LocationData) extends Objective(loc){
  override val name: String = "Dragon"
}
case class Baron(loc : LocationData) extends Objective(loc){
  override val name: String = "Baron"
}
case class Turret(loc : LocationData) extends Objective(loc){
  override val name: String = "Turret"
}
