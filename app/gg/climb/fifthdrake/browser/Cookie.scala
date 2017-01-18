package gg.climb.fifthdrake.browser

/**
  * Created by michael on 1/17/17.
  */
sealed trait Cookie {
  val name: String
}

case object GoogleAuthToken extends Cookie {
  val name = "G_AUTH_USER_TOKEN"
}