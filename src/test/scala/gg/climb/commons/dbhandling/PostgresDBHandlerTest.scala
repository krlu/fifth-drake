package gg.climb.commons.dbhandling

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.{Champion, Game}
import gg.climb.lolobjects.tagging.Tag
import org.joda.time.DateTime
import org.scalatest.{Matchers, WordSpec}
import scalikejdbc.{GlobalSettings, LoggingSQLAndTimeSettings}

class PostgresDBHandlerTest extends WordSpec with Matchers {

  GlobalSettings.loggingSQLAndTime = LoggingSQLAndTimeSettings(
    enabled = false,
    singleLineMode = false,
    printUnprocessedStackTrace = false,
    stackTraceDepth= 15,
    logLevel = 'debug,
    warningEnabled = false,
    warningThresholdMillis = 3000L,
    warningLogLevel = 'warn
  )

  val dbh = PostgresDBHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
  val mdbh = MongoDBHandler()


  "A PostgresDBHandler" should{
    "provide CRUD operations on custom tags" in {
      val data = ("123","test tag", "this is a test", "test", DateTime.now().getMillis,
        Set(RiotId[Player]("44"), RiotId[Player]("45")))
      dbh.insertTag(data)
      val tags: List[Tag] = dbh.getTagsForGame(RiotId[Game]("123"))
      assert(tags.size == 1)
      val tag: Tag = tags(0)
      assert(tag.players.size == 2)
      val newSet = tag.players + mdbh.getPlayer(RiotId[Player]("57"))
      val updatedTag = Tag(tag.id, tag.gameKey, tag.title, tag.description, tag.category, tag.timestamp, newSet)
      dbh.updateTag(updatedTag)
      val newTags = dbh.getTagsForGame(RiotId[Game]("123"))
      val newTag = newTags(0)
      assert(newTag.players.size == 3)
      dbh.deleteTag(updatedTag)
      assert(dbh.getTagsForGame(RiotId[Game]("123")).size == 0)
    }
    "provide querying of champions" in {
      val champion: Champion = dbh.getChampion("Azir")
      assert(champion.name == "Azir")
    }
  }
}
