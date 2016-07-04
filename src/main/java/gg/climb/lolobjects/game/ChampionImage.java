package gg.climb.lolobjects.game;

import org.immutables.value.Value;

import java.io.File;

/**
 * A class that represents a Champion's image. Construct an instance via
 * {@link ChampionImageBuilder}
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class ChampionImage {

  /**
   * @return The file location of this champ's minimap image.
   */
  public abstract File getLocalFile();

  public abstract int getX();

  public abstract int getY();

  public abstract int getWidth();

  public abstract int getHeight();

  public abstract String getSprite();

  public abstract String getFull();

  public abstract String getGroup();
}
