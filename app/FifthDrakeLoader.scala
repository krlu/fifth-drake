import gg.climb.fifthdrake.controllers.{GameDataController, HealthController}
import gg.climb.fifthdrake.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import org.mongodb.scala.MongoClient
import play.api.ApplicationLoader.Context
import play.api.routing.Router
import play.api.{Application, ApplicationLoader, BuiltInComponentsFromContext}
import router.Routes

/**
  * This loader actually loads and runs the application. By explicitly loading
  * the application, we gain compile time dependency injection.
  */
class FifthDrakeLoader extends ApplicationLoader {
  override def load(context: Context): Application =
    new FifthDrakeApp(context).application
}

class FifthDrakeApp(context: Context) extends BuiltInComponentsFromContext(context) {

  lazy val dbh = {
    /* These must all exist in order to actually build the datahandler so we
     * use get to force an error as necessary. */
    val host = context.initialConfiguration.getString("climb.pgHost").get
    val port = context.initialConfiguration.getInt("climb.pgPort").get
    val dbName = context.initialConfiguration.getString("climb.pgDbName").get
    val username = context.initialConfiguration.getString("climb.pgUserName").get
    val password = context.initialConfiguration.getString("climb.pgPassword").get

    new DataAccessHandler(
      new PostgresDbHandler(host, port, dbName, username, password),
      new MongoDbHandler(MongoClient("mongodb://localhost"))
    )
  }

  lazy val gameDataController = new GameDataController(dbh)
  lazy val healthController = new HealthController()
  lazy val assets = new controllers.Assets(httpErrorHandler)
  lazy val router: Router = new Routes(httpErrorHandler,
                                       assets,
                                       gameDataController,
                                       healthController)
}
