package gg.climb.lolobjects.game

import java.net.URL

class MetaData(val patch: String, val vodURL: URL, val seasonId: Int){
  override def toString = s"MetaData(patch=$patch, vodURL=$vodURL, seasonId=$seasonId)"
}

object MetaData {
  def apply(patch: String, vodURL: URL, seasonId: Int) = new MetaData(patch, vodURL, seasonId)
}
