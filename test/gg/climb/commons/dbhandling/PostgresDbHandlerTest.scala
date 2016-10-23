package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.GameData
import gg.climb.lolobjects.tagging.{Category, Tag}
import gg.climb.lolobjects.{InternalId, RiotId}
import org.joda.time.DateTime
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration

class PostgresDbHandlerTest extends WordSpec with Matchers {

  val dbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
//
//  (sys.props("climb.test.pgHost"),
//    sys.props("climb.test.pgPort").toInt,
//    sys.props("climb.test.pgDbName"),
//    sys.props("climb.test.pgUserName"),
//    sys.props("climb.test.pgPassword")
//  )

  "A PostgresDbHandler" should {
    val player1: Player = dbh.getPlayerByRiotId(new RiotId[Player]("44"))
    val player2: Player = dbh.getPlayerByRiotId(new RiotId[Player]("45"))
    "provide CRUD operations on custom tags" in {
      val tagToInsert = new Tag(new RiotId[GameData]("123"), "test tag", "this is a test", new Category("test"),
        Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2)
      )
      dbh.insertTag(tagToInsert)

      val tags: Seq[Tag] = dbh.getTagsForGame(new RiotId[GameData]("123"))
      assert(tags.size == 1)
      val tag: Tag = tags.head
      assert(tag.players.size == 2)
      val newSet: Set[Player] = tag.players + dbh.getPlayerByRiotId(new RiotId[Player]("57"))
      val updatedTag = new Tag(tag.id, tag.gameKey, tag.title, tag.description, tag.category, tag.timestamp, newSet)
      dbh.updateTag(updatedTag)

      val newTags = dbh.getTagsForGame(new RiotId[GameData]("123"))
      val newTag = newTags.head
      assert(newTag.players.size == 3)
      dbh.deleteTag(updatedTag)
      assert(dbh.getTagsForGame(new RiotId[GameData]("123")).isEmpty)
    }
    "provide querying of champions" in {
      val champion = dbh.getChampion("Azir").orNull
      assert(champion.name == "Azir")
    }
    "fail insert operations on tags with existing InternalIds" in {
      val tagToInsert = new Tag(Some(new InternalId[Tag]("123")), new RiotId[GameData]("123"), "test tag",
        "this is a test", new Category("test"), Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2)
      )
      assertThrows[IllegalArgumentException] {
        dbh.insertTag(tagToInsert)
      }
    }
    "fail update operations on custom tags missing InternalIds" in {
      val tagToUpdate = new Tag(new RiotId[GameData]("123"), "test tag", "this is a test", new Category("test"),
        Duration(100, TimeUnit.MILLISECONDS), Set(player1, player2)
      )
      assertThrows[IllegalArgumentException] {
        dbh.updateTag(tagToUpdate)
      }
    }
    "get all teams currently in lcs" in {
      val current_na_lcs_teams = Set("TSM", "CLG", "C9", "IMT", "TL", "NV", "APX", "FOX", "P1", "C9C")
      val current_eu_lcs_teams = Set("G2", "FNC", "OG", "H2K", "SPY", "GIA", "VIT", "UOL", "MSF", "ROC")
      val combined = current_eu_lcs_teams ++ current_na_lcs_teams
      val date = new DateTime().withYear(2016).withMonthOfYear(6).withDayOfMonth(1)
      for (acronym <- combined) {
        val team = dbh.getTeamByAcronym(acronym, Some(date))
        assert(team.players.size >= 5)
        val roles: Traversable[String] = team.players.map(p => p.role.name)
        assert(roles.toSet == Set("jungle", "mid", "top", "bot", "support"))
      }
    }
  }
}
