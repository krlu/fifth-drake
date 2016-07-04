package gg.climb.lolobjects.esports;

import gg.climb.lolobjects.InternalId;
import gg.climb.lolobjects.RiotId;

import org.immutables.value.Value;

import java.util.Collection;
import java.util.Optional;

/**
 * An actual human player represented in League. Use {@link PlayerBuilder} to get an instance.
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class Player {
  public abstract InternalId getInternalId();

  public abstract RiotId getRiotId();

  public abstract String getFirstName();

  public abstract String getLastName();

  public abstract String getIgn();

  public abstract Role getRole();

  public abstract String getRegion();

  public abstract Optional<InternalId> getCurrentTeamId();

  public abstract Collection<InternalId> getTeamIds();
}
