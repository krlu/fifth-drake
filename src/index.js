'use strict';

// Require index.html so it gets copied to dist
require('./index.html');
require('./styles/minimap.scss');
require('./styles/timeline.scss');
require('./styles/divider.scss');

var Elm = require('./elm/Main.elm');
var mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);
