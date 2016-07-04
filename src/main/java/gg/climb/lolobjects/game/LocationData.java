package gg.climb.lolobjects.game;

import org.immutables.value.Value;

import java.util.OptionalDouble;

/**
 * Locational information for an object in a game of League.
 * You can obtain an instance via {@link ImmutableLocationData#of(double, double, OptionalDouble)}
 */
@Value.Immutable(builder = false)
public abstract class LocationData {

  @Value.Parameter(order = 1) public abstract double getX();

  @Value.Parameter(order = 2) public abstract double getY();

  /**
   * @return The confidence of this location information. This is a value that ranges from 0 to 1
   *         and represents how likely this location data is to be accurate.
   */
  @Value.Parameter(order = 3) public abstract OptionalDouble getMatchCoeff();
}
