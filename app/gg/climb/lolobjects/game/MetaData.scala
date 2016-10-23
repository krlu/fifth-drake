package gg.climb.lolobjects.game

import java.net.URL

import gg.climb.lolobjects.RiotId
import org.joda.time.DateTime


class MetaData(val teamName1: String,
               val teamName2: String,
               val gameDate: DateTime,
               val gameKey: RiotId[GameData],
               val patch: String,
               val vodURL: URL,
               val seasonId: Int) {
  override def toString: String = s"MetaData(team1=$teamName1,team2=$teamName2, date=$gameDate," +
    s" gameKey=$gameKey, patch=$patch, vodURL=$vodURL, seasonId=$seasonId)"
}
