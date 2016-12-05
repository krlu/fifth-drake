(function () {
	'use strict';

	require('elm-css/dashboard.css');

	const Elm = require('./Dashboard/Dashboard.elm');
	const mountNode = document.getElementById('Content');

	let script = document.currentScript;

	Elm.Dashboard.embed(mountNode, {
		minimapBackground: require("Dashboard/map.jpg"),
		playButton: require("Dashboard/ic_play_arrow_white_24px.svg"),
		pauseButton: require("Dashboard/ic_pause_white_24px.svg"),
		dataHost: script.getAttribute("data-host")
	});
})();
