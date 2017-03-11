package gg.climb.fifthdrake.lolobjects.game

import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}

class League(val id: InternalId[League], val name: String, val riotId: RiotId[League]){

  override def toString: String = s"id=$id, name=$name, riotId=$riotId)"
}
