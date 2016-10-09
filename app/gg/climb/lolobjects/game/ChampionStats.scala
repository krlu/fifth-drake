package gg.climb.lolobjects.game

/**
 * Champion stats as recorded by riot.
 */
class ChampionStats(attackRange: Double,
                    moveSpeed: Double,
                    attackSpeedOffset: Double,
                    attackSpeedPerLevel: Double,
                    attackDamage: Double,
                    attackDamagePerLevel: Double,
                    hp: Double,
                    hpPerLevel: Double,
                    hpRegen: Double,
                    hpRegenPerLevel: Double,
                    mp: Double,
                    mpPerLevel: Double,
                    mpRegen: Double,
                    mpRegenPerLevel: Double,
                    armor: Double,
                    armorPerLevel: Double,
                    spellBlock: Double,
                    spellBlockPerLevel: Double,
                    crit: Double,
                    critPerLevel: Double){

  override def toString = s"ChampionStats(attackRange=$attackRange, moveSpeed=$moveSpeed," +
    s"attackSpeedOffset=$attackSpeedOffset, attackSpeedPerLevel=$attackSpeedPerLevel, attackDamage=$attackDamage, " +
    s"attackDamagePerLevel=$attackDamagePerLevel, hp=$hp, hpPerLevel=$hpPerLevel, hpRegen=$hpRegen, " +
    s"hpRegenPerLevel=$hpRegenPerLevel, mp=$mp, mpPerLevel=$mpPerLevel, mpRegen=$mpRegen, " +
    s"mpRegenPerLevel=$mpRegenPerLevel, armor=$armor, armorPerLevel=$armorPerLevel, spellBlock=$spellBlock, " +
    s"spellBlockPerLevel=$spellBlockPerLevel, crit=$crit, critPerLevel=$critPerLevel)"
}
