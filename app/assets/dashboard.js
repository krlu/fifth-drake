(function () {
	'use strict';

	require('elm-css/dashboard.css');

	const Elm = require('./Dashboard/Dashboard.elm');
	const mountNode = document.getElementById('dashboard');

	let script = document.currentScript;

	Elm.Dashboard.embed(mountNode, {
		minimapBackground: require("Dashboard/map.jpg"),
		playButton: require("Dashboard/play1.svg"),
		pauseButton: require("Dashboard/pause.svg"),
		location: {
		  host: script.getAttribute("data-host"),
		  gameId: script.getAttribute("data-game-id")
		}
	});
})();
