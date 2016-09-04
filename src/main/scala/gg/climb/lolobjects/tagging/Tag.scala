package gg.climb.lolobjects.tagging

import gg.climb.lolobjects.{InternalId, RiotId}
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.Game

import scala.concurrent.duration.Duration


class Tag(val id: InternalId[Tag], val gameKey: RiotId[Game], val title: String, val description: String,
          val category: Category, val timestamp: Duration, val players: Set[Player]){
  override def toString = s"id=${id.id}, gameKey=${gameKey.id}, title=$title, description=$description, " +
    s"category=${category.name}, timestamp=$timestamp, players=$players"

  /**
    * Returns true if and only if this Tag has an InternalId
    * Tags that do not have InternalIds do not yet exist in a database
    * @return boolean
    */
  def hasInternalId: Boolean = this.id != null
}

object Tag{
  def apply(id: InternalId[Tag],
            gameKey: RiotId[Game],
            title: String,
            description: String,
            category: Category,
            timestamp: Duration,
            players: Set[Player]) = new Tag(id, gameKey,title,description,category,timestamp,players)

  def apply(gameKey: RiotId[Game],
            title: String,
            description: String,
            category: Category,
            timestamp: Duration,
            players: Set[Player]) = new Tag(null, gameKey,title,description,category,timestamp,players)
}