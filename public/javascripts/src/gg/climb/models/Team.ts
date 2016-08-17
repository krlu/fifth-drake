/*
 created by efrawley on 7/30/2016
 */

/// <reference path="Icon.ts" />
/// <reference path="Path.ts" />

/**
 *
 */
class TeamIcons {
    top: Icon;
    jungle: Icon;
    mid: Icon;
    adc: Icon;
    support: Icon;
    constructor() {
        this.top = null;
        this.jungle = null;
        this.mid = null;
        this.adc = null;
        this.support = null;
    }
}

class TeamPaths {
    top:PathSegment;
    jungle:PathSegment;
    mid:PathSegment;
    adc:PathSegment;
    support:PathSegment;
    constructor() {
        this.top = null;
        this.jungle = null;
        this.mid = null;
        this.adc = null;
        this.support = null;
    }
}