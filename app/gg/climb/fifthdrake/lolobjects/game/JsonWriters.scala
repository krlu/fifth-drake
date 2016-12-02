package gg.climb.fifthdrake.lolobjects.game

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.{Game, Time}
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red, TeamState}
import gg.climb.ramenx.Behavior
import play.api.libs.json.{JsArray, JsValue, Json, Writes}

import scala.concurrent.duration.Duration

/**
  * Created by prasanth on 12/1/16.
  */
object JsonWriters {
  implicit def behaviorWrites[A]
      (duration: Time)
      (implicit writer: Writes[A])
      : Writes[Behavior[Time, A]] =
    new Writes[Behavior[Time, A]] {
      override def writes(behavior: Behavior[Time, A]): JsValue = JsArray(
        behavior
          .sampledBy(Duration.Zero, Duration(1, TimeUnit.SECONDS), duration)
          .map(writer.writes)
          .getAll
          .map(_._2)
      )
    }

  implicit val teamStateWrite = new Writes[TeamState] {
    override def writes(teamState: TeamState): JsValue = Json.obj(
      "barons" -> teamState.barons,
      "dragons" -> teamState.dragons,
      "turrets" -> teamState.turrets
    )
  }

  implicit val playerStateWrite = new Writes[PlayerState] {
    override def writes(playerState: PlayerState): JsValue = Json.obj(
      "position" -> Json.obj(
        "x" -> playerState.location.x,
        "y" -> playerState.location.y
      ),
      "championState" -> Json.obj(
        "hp" -> playerState.championState.hp,
        "mp" -> playerState.championState.mp,
        "xp" -> playerState.championState.xp
      ))
  }

  def playerStateToJson(p: (Player, Behavior[Time, PlayerState])): JsValue = p match {
    case (player, states) => Json.obj(
      "side" -> states(Duration.Zero).sideColor.name,
      "role" -> player.role.name,
      "ign" -> player.ign,
      "championName" -> states(Duration.Zero).championState.name,
      "playerStates" -> Json.toJson(states)
    )
  }

  implicit val inGameTeamWrites = new Writes[InGameTeam] {
    override def writes(o: InGameTeam): JsValue = Json.obj(
      "teamStates" -> Json.toJson(o.teamStates),
      "players" -> Json.toJson(o.playerStates.toList.map(playerStateToJson))
    )
  }

  implicit val metaDataWrites = new Writes[MetaData] {
    override def writes(o: MetaData): JsValue = Json.obj(
      "gameLength" -> o.gameDuration.toSeconds,
      "blueTeamName" -> o.blueTeamName,
      "redTeamName" -> o.redTeamName
    )

  }

  implicit val gameDataWrites = new Writes[GameData] {
    override def writes(o: GameData): JsValue = Json.obj(
      "blueTeam" -> Json.toJson(o.teams(Blue)),
      "redTeam" -> Json.toJson(o.teams(Red))
    )
  }

  implicit val gameWrites = new Writes[Game] {
    override def writes(o: (MetaData, GameData)): JsValue = o match {
      case (metadata, data) => Json.obj(
        "metadata" -> Json.toJson(metadata),
        "data" -> Json.toJson(data)
      )
    }
  }
}
