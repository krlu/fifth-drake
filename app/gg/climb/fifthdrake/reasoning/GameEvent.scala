package gg.climb.fifthdrake.reasoning

import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{LocationData, Side}

import scala.concurrent.duration.Duration


sealed trait GameEvent
case class FightEvent(fight: Fight) extends GameEvent

sealed class Fight(val playersInvolved: Set[Player], val location: LocationData)
case class Gank(players: Set[Player], loc: LocationData) extends Fight(players, loc)
case class Teamfight(players: Set[Player], loc: LocationData) extends Fight(players, loc)
case class Skirmish(players: Set[Player], loc: LocationData) extends Fight(players, loc)

class Objective(location : LocationData, timestamp: Duration) extends GameEvent
case class DragonKill(loc: LocationData, dragonType: Dragon, time: Duration) extends Objective(loc, time)
case class BaronKill(loc: LocationData, time: Duration) extends Objective(loc, time)
case class BuildingKill(loc: LocationData, buildingType: Building,
                        lane: Lane, side: Side, time: Duration) extends Objective(loc, time)

sealed class Dragon(val name : String)
case class AirDragon() extends Dragon("AirDragon")
case class EarthDragon() extends Dragon("EarthDragon")
case class FireDragon() extends Dragon("FireDragon")
case class WaterDragon() extends Dragon("WaterDragon")
case class ElderDragon() extends Dragon("ElderDragon")

sealed class Building(val name: String)
case class OuterTurret() extends Building("OuterTurret")
case class InnerTurret() extends Building("InnerTurret")
case class BaseTurret() extends Building("BaseTurret")
case class NexusTurret() extends Building("NexusTurret")
case class Inhibitor() extends Building("Inhibitor")

sealed class Lane(val name: String)
case class Top() extends Lane("Top")
case class Middle() extends Lane("Middle")
case class Bottom() extends Lane("Bottom")
