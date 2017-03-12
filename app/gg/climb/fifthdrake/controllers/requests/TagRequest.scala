package gg.climb.fifthdrake.controllers.requests

import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.{GameData, MetaData}
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import play.api.mvc.{ActionRefiner, Result, WrappedRequest}

import scala.concurrent.Future

/**
  * Created by michael on 3/4/17.
  */
class TagRequest[A](val gameTags: Seq[Tag], request: AuthenticatedRequest[A]) extends WrappedRequest[A](request)

object TagAction {
  /**
    * This refiner responds to a load tag request by filtering tags visible only by the particular user group
    *
    * @param gameKey
    * @param dbh
    * @return
    */
  def refiner(gameKey: String, dbh: DataAccessHandler): ActionRefiner[AuthenticatedRequest, TagRequest] =
    new ActionRefiner[AuthenticatedRequest, TagRequest] {
      override protected def refine[A](request: AuthenticatedRequest[A]): Future[Either[Result, TagRequest[A]]] =
        Future.successful {
          dbh.getUserGroup(request.user) match {
            case Some(userGroup) =>
              val tags = dbh.getTags(new RiotId[(MetaData, GameData)](gameKey))
                .filter(t => t.authorizedGroups.map(g => g.uuid).contains(userGroup.uuid))
              Right(new TagRequest[A](tags, request))
            case None =>
              Right(new TagRequest[A](Seq.empty, request))
          }
        }
    }
}
