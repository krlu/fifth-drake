package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.{InternalId, RiotId}
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.{Champion, Game}
import gg.climb.lolobjects.tagging.{Category, Tag}
import org.scalatest.{Matchers, WordSpec}
import scalikejdbc.{GlobalSettings, LoggingSQLAndTimeSettings}

import scala.concurrent.duration.Duration

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

    val player1 = mdbh.getPlayer(RiotId[Player]("44"))
    val player2 = mdbh.getPlayer(RiotId[Player]("45"))

    "provide CRUD operations on custom tags" in {
      val tagToInsert = Tag(RiotId[Game]("123"), "test tag", "this is a test", Category("test"),
        Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2))
      dbh.insertTag(tagToInsert)

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
    "fail insert operations on tags with existing InternalIds" in {
      val tagToInsert = Tag(InternalId[Tag]("123"), RiotId[Game]("123"), "test tag", "this is a test", Category("test"),
        Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2))
      assertThrows[IllegalArgumentException] {
        dbh.insertTag(tagToInsert)
      }
    }
    "fail update operations on custom tags missing InternalIds" in {
      val tagToUpdate = Tag(RiotId[Game]("123"), "test tag", "this is a test", Category("test"),
        Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2))
      assertThrows[IllegalArgumentException] {
        dbh.updateTag(tagToUpdate)
      }
    }
  }
}
