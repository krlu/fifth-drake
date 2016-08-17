/*
 created by efrawley on 7/30/2016
 */
///<reference path="Team.ts" />
/**
 *
 */
var PathInstance = (function () {
    function PathInstance() {
        this.bluePaths = null;
        this.redPaths = null;
    }
    return PathInstance;
}());
/**
 * Literally just a point
 */
var Point = (function () {
    function Point(x, y) {
        this.x = x;
        this.y = y;
    }
    Point.prototype.toString = function () {
        return "x: " + this.x + ", y: " + this.y;
    };
    return Point;
}());
/**
 * Path representation from one point to another
 */
var PathSegment = (function () {
    function PathSegment(point1, point2, color) {
        this.point1 = point1;
        this.point2 = point2;
    }
    PathSegment.prototype.toString = function () {
        return "point1 (x, y): (" + this.point1.x + ", " + this.point1.y +
            ") and point2 (x, y): (" + this.point2.x, ", " + this.point2.y + ")";
    };
    PathSegment.prototype.makeVisible = function (color) {
        return color;
    };
    return PathSegment;
}());
//# sourceMappingURL=Path.js.map