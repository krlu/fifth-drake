package gg.climb.fifthdrake.reasoning

import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{LocationData, Side}

import scala.concurrent.duration.Duration


sealed trait GameEvent
case class FightEvent(fight: Fight) extends GameEvent
class Objective(location : LocationData, timestamp: Duration) extends GameEvent

sealed class Fight(val playersInvolved: Set[Player], val location: LocationData)
case class Gank(players: Set[Player], loc: LocationData) extends Fight(players, loc)
case class Teamfight(players: Set[Player], loc: LocationData) extends Fight(players, loc)
case class Skirmish(players: Set[Player], loc: LocationData) extends Fight(players, loc)

case class DragonKill(loc: LocationData, dragonType: Dragon, time: Duration) extends Objective(loc, time)
case class BaronKill(loc: LocationData, time: Duration) extends Objective(loc, time)
case class BuildingKill(loc: LocationData, buildingType: Building,
                        lane: Lane, side: Side, time: Duration) extends Objective(loc, time)

sealed trait Dragon{
  val name : String
}

case object FireDragon extends Dragon{
  override val name = "Fire Dragon"
}
case object EarthDragon extends Dragon{
  override val name = "Mountain Dragon"
}
case object WaterDragon extends Dragon{
  override val name = "Water Dragon"
}
case object AirDragon extends Dragon{
  override val name = "Air Dragon"
}

sealed trait Building{
  val name: String
}

case object OuterTurret extends Building{
  override val name = "Outer Turret"
}

case object InnerTurret extends Building{
  override val name = "Inner Turret"
}

case object BaseTurret extends Building{
  override val name = "Base Turret"
}

case object NexusTurret extends Building{
  override val name = "Nexus Turret"
}

case object Inhibitor extends Building{
  override val name = "Inhibitor"
}

sealed trait Lane{
  val name: String
}

case object Top extends Lane{
  override val name = "Top"
}

case object Middle extends Lane{
  override val name = "Middle"
}

case object Bottom extends Lane{
  override val name = "Bottom"
}
