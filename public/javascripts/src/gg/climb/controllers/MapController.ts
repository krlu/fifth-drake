/*
 created by efrawley on 7/30/2016
 */

/// <reference path="IconController.ts" />
/// <reference path="PathController.ts" />
/// <reference path="SliderController.ts" />
/// <reference path="../models/Path.ts" />
/// <reference path="../resources/d3.d.ts" />

'use strict';
import Path = d3.geo.Path;
import mouse = d3.mouse;
import PathingHandler from "./PathController";

class Minimap {

    icons: IconHandler;
    slider: SliderHandler;
    paths: PathingHandler;

    constructor() {
        this.icons = new IconHandler();
        this.slider = new SliderHandler();
        this.paths = new PathingHandler();
    }

}