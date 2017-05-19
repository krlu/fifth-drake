package gg.climb.fifthdrake.reasoning

import java.awt.Polygon

import gg.climb.fifthdrake._
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state._

/**
  * Created by Kenneth on 5/18/2017.
  */
object LocationReasoning {

  private val baseRadius = 6546
  private val upperJunglePolygon = List(
    (9462.890625, 13300.78125),
    (4365.234375, 13300.78125),
    (1933.59375, 10136.71875),
    (1933.59375, 5859.375),
    (4335.9375, 5185.546875),
    (10341.796875, 10810.546875))

  private val lowerJunglePolygon = List(
    (11162.109375, 9960.9375),
    (5126.953125, 4335.9375),
    (6035.15625, 1787.109375),
    (11132.8125, 1787.109375),
    (13535.15625, 5097.65625),
    (13535.15625, 9257.8125))

  def createLineChecker(p1: (Double, Double), p2: (Double, Double)): (Double, Double) => Boolean = {
    val m = (p2._2 - p1._2)/(p1._1 - p1._1)
    val b = p1._2 - m * p1._1
    (x : Double, y : Double) => y == m*x + b
  }

  def getLocationType(player : Player, prevState : PlayerState, state: PlayerState) : LocationType = {
    val prevLoc = prevState.location
    if(inBase(prevLoc))
      InBase
    else if(inJunglePolygons(prevLoc))
      InJungle
    else
      InLane
  }
  private def inBase(loc : LocationData) = {
    val bottomLeft = new LocationData(0, 0, 1.0)
    val topRight = new LocationData(15000, 15000, 1.0)
    distance(bottomLeft, loc) < baseRadius || distance(topRight, loc) < baseRadius
  }
  private def inJunglePolygons(loc : LocationData): Boolean = {
    val jungleRegions = List(lowerJunglePolygon, upperJunglePolygon)
    jungleRegions.exists { region =>
      val (xList, yList) = region.map { case (x, y) => (x.toInt, y.toInt) }.unzip
      val xArr = xList.toArray
      val yArr = yList.toArray
      val pol = new Polygon(xArr, yArr, 6)
      pol.contains(loc.x, loc.y)
    }
  }
}

sealed  trait LocationType
case object InLane extends LocationType
case object InJungle extends LocationType
case object InBase extends LocationType
