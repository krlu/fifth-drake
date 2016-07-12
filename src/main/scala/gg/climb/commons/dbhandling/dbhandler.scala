import java.time.LocalTime

import scalikejdbc._

class dbhandler(host: String, port: Int, db : String,  user : String, password: String) {

  val url = "jdbc:postgresql://%s:%d/%s".format(host, port, db)

  ConnectionPool.singleton(url, user, password)
  val lcs_game: List[WrappedResultSet] = DB readOnly { implicit session =>
    sql"select * from league.game_identifier".map(s => s).list.apply()
  }
  for(rs <- lcs_game){
    println(rs)
  }
}

object dbhandler{
  def main(args: Array[String]): Unit ={
    val dbh = new dbhandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
  }


}
