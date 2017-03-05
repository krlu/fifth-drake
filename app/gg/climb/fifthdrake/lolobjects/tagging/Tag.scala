package gg.climb.fifthdrake.lolobjects.tagging

import gg.climb.fifthdrake.lolobjects.accounts.UserGroup
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.{Game, Time}


class Tag(val id: Option[InternalId[Tag]],
          val gameKey: RiotId[Game],
          val title: String,
          val description: String,
          val category: Category,
          val timestamp: Time,
          val players: Set[Player],
          val author: String,
          val authorizedGroups: List[UserGroup]) {

  def this(gameKey: RiotId[Game],
           title: String,
           description: String,
           category: Category,
           timestamp: Time,
           players: Set[Player],
           author: String,
           authorizedGroups: List[UserGroup]) {
    this(Option.empty,
         gameKey,
         title,
         description,
         category,
         timestamp,
         players,
         author,
         authorizedGroups
    )
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
