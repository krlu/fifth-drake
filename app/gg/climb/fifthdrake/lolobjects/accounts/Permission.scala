package gg.climb.fifthdrake.lolobjects.accounts

trait Permission {
  val name: String
  override def toString: String = name
}

case object Owner extends  Permission {
  override val name = "owner"
}

case object Admin extends  Permission {
  override val name = "admin"
}

case object Member extends  Permission {
  override val name = "member"
}
