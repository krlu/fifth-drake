package gg.climb.fifthdrake.lolobjects.game

import java.net.URL

import gg.climb.fifthdrake.Time
import gg.climb.fifthdrake.lolobjects.RiotId
import org.joda.time.DateTime


class MetaData(val blueTeamName: String,
               val redTeamName: String,
               val gameDate: DateTime,
               val gameKey: RiotId[GameData],
               val patch: String,
               val vodURL: URL,
               val seasonId: Int,
               val gameDuration: Time) {
  override def toString: String = s"MetaData(team1=$blueTeamName,team2=$redTeamName, date=$gameDate," +
    s" gameKey=$gameKey, patch=$patch, vodURL=$vodURL, seasonId=$seasonId, gameDuration=$gameDuration)"
}
