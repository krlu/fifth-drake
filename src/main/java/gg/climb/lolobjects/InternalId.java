package gg.climb.lolobjects;

import org.immutables.value.Value;

/**
 * Representation of our internal database ids. You can obtain a new instance via
 * {@link ImmutableInternalId#of(int)}. However, this class should not be used in
 * most cases outside of the database.
 */
@SuppressWarnings("unused") // Actually used type parameter
@Value.Immutable(builder = false)
public abstract class InternalId<T> {
  @Value.Parameter
  public abstract int getId();
}
