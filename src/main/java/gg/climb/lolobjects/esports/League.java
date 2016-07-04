package gg.climb.lolobjects.esports;

import gg.climb.lolobjects.RiotId;

import org.immutables.value.Value;

/**
 * A league format such as LCK or NALCS. Create an instance via
 * {@link ImmutableLeague#of(RiotId, String)}
 */
@Value.Immutable(builder = false)
public abstract class League {
  @Value.Parameter public abstract RiotId getId();

  @Value.Parameter public abstract String getName();
}
