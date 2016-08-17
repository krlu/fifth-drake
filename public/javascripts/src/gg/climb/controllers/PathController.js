/*
 created by efrawley on 7/30/2016
 */
"use strict";
///<reference path="../models/Path.ts" />
/// <reference path="../../../../resources/d3.d.ts" />
var index_1 = require("../../../../node_modules/typescript-collections/dist/lib/index");
'use strict';
/**
 * Handles the player pathing on the minimap
 */
var PathingHandler = (function () {
    function PathingHandler() {
        this.addPathInstance = function (pathInstance) {
            this.paths.add(pathInstance);
        };
        this.removeFirstPathInstance = function () {
            this.paths.dequeue();
        };
        this.next = function (pathInstance) {
            this.removeFirstPathInstance();
            this.addPathInstance(pathInstance);
        };
        this.paths = new index_1.Queue();
    }
    return PathingHandler;
}());
exports.__esModule = true;
exports["default"] = PathingHandler;
//# sourceMappingURL=PathController.js.map