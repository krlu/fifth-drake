/*
 created by efrawley on 7/30/2016
 */

///<reference path="Team.ts" />

/**
 *
 */
class PathInstance {
    bluePaths:TeamPaths;
    redPaths:TeamPaths;
    constructor() {
        this.bluePaths = null;
        this.redPaths = null;
    }
}

/**
 * Literally just a point
 */
class Point {
    x: number;
    y: number;
    constructor(x: number, y: number) {
        this.x = x;
        this.y = y;
    }
    toString() {
        return "x: " + this.x + ", y: " + this.y;
    }
}

/**
 * Path representation from one point to another
 */
class PathSegment {
    point1:Point;
    point2:Point;
    constructor(point1: Point, point2: Point, color: string) {
        this.point1 = point1;
        this.point2 = point2;
    }
    toString() {
        return "point1 (x, y): (" + this.point1.x + ", " + this.point1.y +
        ") and point2 (x, y): (" + this.point2.x, ", " + this.point2.y + ")";
    }
    makeVisible(color: string) {
        return color;
    }
}