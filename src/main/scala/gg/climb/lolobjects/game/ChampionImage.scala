package gg.climb.lolobjects.game

import java.io.File

/**
 * A class that represents a Champion's image.
 */
class ChampionImage(val file: File, val x: Int, val y: Int, val w: Int,
                    val h: Int, val sprite: String, val full: String, val group: String)

object ChampionImage{
  def apply(file: File, x: Int, y: Int,
            w: Int, h: Int, sprite: String,
            full: String, group: String) = new ChampionImage(file, x, y, w, h, sprite, full, group)
}
