package gg.climb.lolobjects.game;

import gg.climb.lolobjects.InternalId;
import gg.climb.lolobjects.RiotId;

import org.immutables.value.Value;

/**
 * A class that represents a champion in League. Obtain an instance via {@link ChampionBuilder}.
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class Champion {
  public abstract InternalId getInternalId();

  public abstract String getName();

  public abstract RiotId getRiotId();

  public abstract ChampionStats getStats();

  public abstract ChampionImage getImage();
}
