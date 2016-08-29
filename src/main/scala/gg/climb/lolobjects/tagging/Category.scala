package gg.climb.lolobjects.tagging

class Category(val name: String){
  override def toString = s"category:$name"
}

object Category{
  def apply(name: String) = new Category(name)
}

