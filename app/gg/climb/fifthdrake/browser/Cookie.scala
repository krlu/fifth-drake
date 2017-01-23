package gg.climb.fifthdrake.browser

/**
  * Cookies are retrieved and set through Play using Strings for keys.
  * This trait ensures we are setting and retrieving the correct cookies and with minimal mistakes.
  *
  * Created by michael on 1/17/17.
  */
sealed trait Cookie {
  val name: String
}

case object GoogleAuthToken extends Cookie {
  val name = "G_AUTH_USER_TOKEN"
}
