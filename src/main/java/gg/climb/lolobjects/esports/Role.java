package gg.climb.lolobjects.esports;

/**
 * Represents the various positions that can be held in League.
 */
public enum Role {
  TOP("top"),
  JUNGLE("jungle"),
  MID("mid"),
  ADC("adc"),
  SUPPORT("support");

  private String name;

  Role(String name) {
    this.name = name;
  }

  /**
   * Parses Riot's name for each role into a Role.
   * @param role riot's name for a role in their API.
   * @return The appropriate role.
   */
  public static Role interpret(String role) {
    switch (role) {
      case "toplane":
        return Role.TOP;
      case "jungle":
        return Role.JUNGLE;
      case "midlane":
        return Role.MID;
      case "adcarry":
        return Role.ADC;
      case "support":
        return Role.SUPPORT;
      default:
        throw new IllegalArgumentException(String.format("`%s' is not a valid role", role));
    }
  }

  @Override
  public String toString() {
    return this.name;
  }
}

