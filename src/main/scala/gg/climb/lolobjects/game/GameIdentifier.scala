package gg.climb.lolobjects.game

import gg.climb.lolobjects.RiotId
import org.joda.time.DateTime


class GameIdentifier(val teamName1: String, val teamName2: String,
										 val gameDate: DateTime, val gameKey: RiotId[Game], val metaData: MetaData){

	override def toString = s"GameIdentifier(team1=$teamName1,team2=$teamName2, " +
                          s"date=$gameDate, gameKey=$gameKey, metaData=$metaData)"
}
