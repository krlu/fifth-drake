package gg.climb.fifthdrake.lolobjects.esports

/**
  * Represents the various positions that can be held in League.
  */
sealed class Role(val name: String)

case object Top extends Role("top")
case object Jungle extends Role("jungle")
case object Mid extends Role("mid")
case object Bot extends Role("bot")
case object Support extends Role("support")

object Role {
  /**
    * Parses Riot's name for each role into a Role.
    *
    * @param s riot's name for a role in their API.
    * @return The appropriate role.
    */
  def interpret(s: String): Role = s.toLowerCase match {
    case "toplane" => Top
    case "jungle" => Jungle
    case "midlane" => Mid
    case "adcarry" => Bot
    case "support" => Support
    case _ => throw new IllegalArgumentException(String.format("`%s' is not a valid role", s));
  }

  def compare(actual: Role, expected: Role): Boolean = {
    actual match {
      case `expected` => true
      case _ => false
    }
  }
}
