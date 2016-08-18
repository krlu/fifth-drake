package gg.climb.lolobjects.game

import gg.climb.lolobjects.RiotId
import org.joda.time.DateTime


class GameIdentifier(val teamName1: String, val teamName2: String,
										 val gameDate: DateTime, val gameKey: RiotId[Game], val metaData: MetaData){

	override def toString = s"GameIdentifier(team1=$teamName1,team2=$teamName2, " +
                          s"date=$gameDate, gameKey=$gameKey, metaData=$MetaData)"
}
object GameIdentifier{
  def apply(teamName1: String,teamName2: String, gameDate: DateTime, gameKey: RiotId[Game], metaData: MetaData) =
    new GameIdentifier(teamName1, teamName2, gameDate, gameKey, metaData)
}
