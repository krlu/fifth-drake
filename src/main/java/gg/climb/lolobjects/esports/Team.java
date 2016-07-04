package gg.climb.lolobjects.esports;

import gg.climb.lolobjects.InternalId;
import gg.climb.lolobjects.RiotId;

import org.immutables.value.Value;

import java.util.Collection;

/**
 * Represents a physical team such as TSM or CLG. Use {@link TeamBuilder} to make a new team.
 * Careful however as that class will eventually be deprecated in favor of Dynamic queue.
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class Team {
  public abstract InternalId getInternalId();

  public abstract RiotId getRiotId();

  public abstract String getName();

  public abstract String getAcronym();

  public abstract Collection<Player> getPlayers();
}
