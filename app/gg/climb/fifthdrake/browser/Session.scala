package gg.climb.fifthdrake.browser

/**
  * Created by michael on 2/11/17.
  */
sealed trait Session {
  val name: String
}

case object UserId extends Session {
  val name = "UserId"
}
