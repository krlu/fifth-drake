package gg.climb.fifthdrake.lolobjects.game

import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}

class GameIdentifier(val id: InternalId[GameIdentifier],
                     val gameKey: RiotId[GameIdentifier],
                     val blueTeamName: String,
                     val redTeamName: String,
                     val tournament: Tournament,
                     val week: Int,
                     val gameNumber: Int) {

  override def toString: String = s"GameIdentifier(id=$id, gameKey=$gameKey, blueTeam=$blueTeamName," +
    s"redTeam=$redTeamName, tourney=$tournament, week=$week, gameNumber=$gameNumber)"
}
