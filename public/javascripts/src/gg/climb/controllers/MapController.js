/*
 created by efrawley on 7/30/2016
 */
/// <reference path="IconController.ts" />
/// <reference path="PathController.ts" />
/// <reference path="SliderController.ts" />
/// <reference path="../models/Path.ts" />
/// <reference path="../../../../resources/d3.d.ts" />
'use strict';
var PathController_1 = require("./PathController");
var Minimap = (function () {
    function Minimap() {
        this.icons = new IconHandler();
        this.slider = new SliderHandler();
        this.paths = new PathController_1["default"]();
    }
    return Minimap;
}());
//# sourceMappingURL=MapController.js.map