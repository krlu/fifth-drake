import gg.climb.fifthdrake.controllers.{GameDataController, HealthController}
import play.api.ApplicationLoader.Context
import play.api.routing.Router
import play.api.{Application, ApplicationLoader, BuiltInComponentsFromContext}
import router.Routes

/**
  * Created by prasanth on 10/25/16.
  */
class FifthDrakeLoader extends ApplicationLoader {
  override def load(context: Context): Application =
    new FifthDrakeApp(context).application
}

class FifthDrakeApp(context: Context) extends BuiltInComponentsFromContext(context) {
  lazy val gameDataController = new GameDataController()
  lazy val healthController = new HealthController()
  lazy val assets = new controllers.Assets(httpErrorHandler)
  lazy val router: Router = new Routes(httpErrorHandler,
                                       assets,
                                       gameDataController,
                                       healthController)
}
