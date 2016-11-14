(function () {
	'use strict';

	require('./styles/content.scss');
	require('./styles/minimap.scss');
	require('./styles/timeline.scss');
	require('./styles/tag-scroller.scss');
	require('./styles/divider.scss');

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
