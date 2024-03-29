import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter}
import gg.climb.fifthdrake.controllers.{AppDataController, GameDataController, HealthController, HomePageController}
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

  private lazy val googleClientId = context.initialConfiguration.getString("climb.googleClientId").get
  private lazy val googleClientSecret = context.initialConfiguration.getString("climb.googleClientSecret").get

  lazy val AuthenticatedAction = new AuthenticatedAction(dbh)
  lazy val AuthorizationFilter = new AuthorizationFilter(dbh)

  lazy val homePageController = new HomePageController(dbh, googleClientId, googleClientSecret, AuthenticatedAction)
  lazy val gameDataController = new GameDataController(dbh, AuthenticatedAction, AuthorizationFilter)
  lazy val healthController = new HealthController()
  lazy val appDataController = new AppDataController(dbh, AuthenticatedAction, AuthorizationFilter)
  lazy val assets = new controllers.Assets(httpErrorHandler)
  lazy val router: Router = new Routes(
    httpErrorHandler,
    homePageController,
    assets,
    healthController,
    gameDataController,
    appDataController
  )
}
