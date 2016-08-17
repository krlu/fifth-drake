/*
 created by efrawley on 7/30/2016
 */

///<reference path="../models/Path.ts" />
/// <reference path="../../../../resources/d3.d.ts" />

import {Queue} from "../../../../node_modules/typescript-collections/dist/lib/index";

'use strict';
import path = d3.geo.path;

/**
 * Handles the player pathing on the minimap
 */
class PathingHandler {

    paths:Queue<PathInstance>;
    constructor() {
        this.paths = new Queue<PathInstance>();
    }

    addPathInstance = function(pathInstance:PathInstance){
        this.paths.add(pathInstance);
    }

    removeFirstPathInstance = function() {
        this.paths.dequeue();
    }

    next = function(pathInstance:PathInstance) {
        this.removeFirstPathInstance();
        this.addPathInstance(pathInstance)
    }

}

export default PathingHandler;