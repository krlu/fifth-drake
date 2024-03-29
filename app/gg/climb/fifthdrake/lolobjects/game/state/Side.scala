package gg.climb.fifthdrake.lolobjects.game.state

import gg.climb.fifthdrake.lolobjects.RiotId

sealed trait Side {
  val name: String
  val riotId: RiotId[Side]

  override def toString: String = name
}

case object Red extends Side {
  override val name = "red"
  override val riotId = new RiotId[Side]("100")
}

case object Blue extends Side {
  override val name = "blue"
  override val riotId = new RiotId[Side]("200")
}
