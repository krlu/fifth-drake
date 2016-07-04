package gg.climb.lolobjects;

import org.immutables.value.Value;

/**
 * Representation of Riot's Id numbers. You can obtain a RiotId through
 * {@link ImmutableRiotId#of(String)}. However, you likely should not be building this class outside
 * of database access and downloading from Riot's servers.
 */
@SuppressWarnings("unused") // Actually used type parameter
@Value.Immutable(builder = false)
public abstract class RiotId<T> {
  @Value.Parameter
  public abstract String getId();
}
