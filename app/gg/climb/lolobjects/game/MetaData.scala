package gg.climb.lolobjects.game

import java.net.URL

class MetaData(val patch: String, val vodURL: URL, val seasonId: Int) {
  override def toString: String = s"MetaData(patch=$patch, vodURL=$vodURL, seasonId=$seasonId)"
}
