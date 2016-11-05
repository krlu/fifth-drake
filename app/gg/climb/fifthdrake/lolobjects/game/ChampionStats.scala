package gg.climb.fifthdrake.lolobjects.game

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
                    critPerLevel: Double) {

  override def toString: String =
    s"ChampionStats(attackRange=$attackRange, " +
      s"moveSpeed=$moveSpeed," +
      s"attackSpeedOffset=$attackSpeedOffset," +
      s"attackSpeedPerLevel=$attackSpeedPerLevel," +
      s"attackDamage=$attackDamage," +
      s"attackDamagePerLevel=$attackDamagePerLevel," +
      s"hp=$hp," +
      s"hpPerLevel=$hpPerLevel," +
      s"hpRegen=$hpRegen," +
      s"hpRegenPerLevel=$hpRegenPerLevel," +
      s"mp=$mp," +
      s"mpPerLevel=$mpPerLevel," +
      s"mpRegen=$mpRegen," +
      s"mpRegenPerLevel=$mpRegenPerLevel," +
      s"armor=$armor," +
      s"armorPerLevel=$armorPerLevel," +
      s"spellBlock=$spellBlock," +
      s"spellBlockPerLevel=$spellBlockPerLevel," +
      s"crit=$crit," +
      s"critPerLevel=$critPerLevel)"
}
