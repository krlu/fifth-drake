package gg.climb.lolobjects.game;

import org.immutables.value.Value;

/**
 * Champion stats as recorded by riot. See {@link ChampionStatsBuilder}
 */
@Value.Style(visibility = Value.Style.ImplementationVisibility.PRIVATE,
             strictBuilder = true)
@Value.Immutable
public abstract class ChampionStats {
  public abstract double attackRange();

  public abstract double moveSpeed();

  public abstract double attackSpeedOffset();

  public abstract double attackSpeedPerLevel();

  public abstract double attackDamage();

  public abstract double attackDamagePerLevel();

  public abstract double hp();

  public abstract double hpPerLevel();

  public abstract double hpRegen();

  public abstract double hpRegenPerLevel();

  public abstract double mp();

  public abstract double mpPerLevel();

  public abstract double mpRegen();

  public abstract double mpRegenPerLevel();

  public abstract double armor();

  public abstract double armorPerLevel();

  public abstract double spellBlock();

  public abstract double spellBlockPerLevel();

  public abstract double crit();

  public abstract double critPerLevel();

}
