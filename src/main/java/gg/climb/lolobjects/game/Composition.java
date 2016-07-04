package gg.climb.lolobjects.game;

import org.immutables.value.Value;

import java.util.Arrays;
import java.util.List;

/**
 * Represents a team composition that can be used for each side of the map. You may obtain an
 * instance through {@link CompositionBuilder}
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class Composition {
  public abstract Champion getTop();

  public abstract Champion getJungle();

  public abstract Champion getMid();

  public abstract Champion getAdc();

  public abstract Champion getSupport();

  @Value.Derived
  public List<Champion> getChampions() {
    return Arrays.asList(getTop(), getJungle(), getMid(), getAdc(), getSupport());
  }
}
