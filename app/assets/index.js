(function () {
	'use strict';

	require("elm-css/dashboard.css");

	const Elm = require('./elm/Main.elm');
	const mountNode = document.getElementById('main');

	let script = document.currentScript;

	Elm.Main.embed(mountNode, {
		minimapBackground: require("map.jpg"),
		playButton: require("play1.svg"),
		pauseButton: require("pause.svg"),
		location: {
		  host: script.getAttribute("data-host"),
		  gameId: script.getAttribute("data-game-id")
		}
	});
})();
