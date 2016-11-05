package gg.climb.fifthdrake.lolobjects.tagging

import gg.climb.fifthdrake.Time
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.GameData
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}


class Tag(val id: Option[InternalId[Tag]],
          val gameKey: RiotId[GameData],
          val title: String,
          val description: String,
          val category: Category,
          val timestamp: Time,
          val players: Set[Player]) {

  def this(gameKey: RiotId[GameData],
           title: String,
           description: String,
           category: Category,
           timestamp: Time,
           players: Set[Player]) {
    this(Option.empty,
         gameKey,
         title,
         description,
         category,
         timestamp,
         players)
  }

  override def toString: String = s"id=$id, gameKey=${
    gameKey
    .id
  }, title=$title, description=$description, " +
    s"category=${category.name}, timestamp=$timestamp, players=$players"

  /**
    * Returns true if and only if this Tag has an InternalId
    * Tags that do not have InternalIds do not yet exist in a database
    *
    * @return boolean
    */
  def hasInternalId: Boolean = this.id.isDefined
}
