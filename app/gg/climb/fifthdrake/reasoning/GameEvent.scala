package gg.climb.fifthdrake.reasoning

import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.{Player, Role}
import gg.climb.fifthdrake.lolobjects.game.state.{LocationData, Side}

import scala.concurrent.duration.Duration


sealed abstract class GameEvent(val location: LocationData, val timestamp: Duration)

sealed class Fight(val playersInvolved: Set[Player],
                   override val location: LocationData,
                   override val timestamp: Duration) extends GameEvent(location, timestamp)

case class Gank(players: Set[Player], loc: LocationData, time: Duration) extends Fight(players, loc, time)
case class Teamfight(players: Set[Player], loc: LocationData, time: Duration) extends Fight(players, loc, time)
case class Skirmish(players: Set[Player], loc: LocationData, time: Duration) extends Fight(players, loc, time)

class Objective(override val location: LocationData,
                override val timestamp: Duration,
                val killerId : RiotId[(Side, Role)]) extends GameEvent(location, timestamp)

case class DragonKill(loc: LocationData, dragonType: Dragon, time: Duration,
                      killer : RiotId[(Side, Role)]) extends Objective(loc, time, killer)

case class BaronKill(loc: LocationData, time: Duration,
                     killer : RiotId[(Side, Role)]) extends Objective(loc, time, killer)

case class BuildingKill(loc: LocationData, buildingType: Building, lane: Lane, side: Side,
                        time: Duration, killer : RiotId[(Side, Role)]) extends Objective(loc, time, killer)


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
