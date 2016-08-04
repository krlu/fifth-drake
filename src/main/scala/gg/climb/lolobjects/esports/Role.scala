package gg.climb.lolobjects.esports

/**
 * Represents the various positions that can be held in League.
 */
abstract class Role {
  val name: String
  override def toString = name
}

case class Top() extends Role {
  override val name: String = "top"
}
case class Jungle() extends Role {
  override val name: String = "jungle"
}
case class Mid() extends Role {
  override val name: String = "mid"
}
case class Bot() extends Role {
  override val name: String = "bot"
}
case class Support() extends Role {
  override val name: String = "support"
}

object Role {
  /**
   * Parses Riot's name for each role into a Role.
   * @param s riot's name for a role in their API.
   * @return The appropriate role.
   */
  def interpret(s: String): Role  = s.toLowerCase match {
    case "toplane" => Top()
    case "jungle" => Jungle()
    case "midlane" => Mid()
    case "adcarry" => Bot()
    case "support" => Support()
    case _ => throw new IllegalArgumentException(String.format("`%s' is not a valid role", s));
  }
}
