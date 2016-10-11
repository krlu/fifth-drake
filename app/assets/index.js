(function () {
	'use strict';

    // Require index.html so it gets copied to dist
	require('./index.html');
	require('./styles/minimap.scss');
	require('./styles/timeline.scss');
	require('./styles/divider.scss');

	const Elm = require('./elm/Main.elm');
	const mountNode = document.getElementById('main');

	Elm.Main.embed(mountNode, {
		minimapBackground: require("map.jpg"),
		playButton: require("play1.svg"),
		pauseButton: require("pause.svg")
	});
})();
