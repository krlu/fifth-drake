package gg.climb.lolobjects.game;

import gg.climb.lolobjects.esports.Player;
import gg.climb.lolobjects.esports.PlayerBuilder;
import org.immutables.value.Value;

/**
 * An actual human player represented in League. Use {@link PlayerBuilder} to get an instance.
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
    strictBuilder = true)
@Value.Immutable
public abstract class PlayerState {

  public abstract long getTimeStamp();

  public abstract Player getSummoner();

  public abstract String getChampionName();

  public abstract double getHp();

  public abstract double getMp();

  public abstract double getXP();

  public abstract LocationData location();
}
