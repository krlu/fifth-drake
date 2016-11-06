(function () {
	'use strict';
  // Require index.html so it gets copied to dist
	require('./styles/content.scss');
	require('./styles/minimap.scss');
	require('./styles/timeline.scss');
	require('./styles/tag-scroller.scss');
	require('./styles/divider.scss');

	const Elm = require('./elm/Main.elm');
	const mountNode = document.getElementById('main');

	Elm.Main.embed(mountNode, {
		minimapBackground: require("map.jpg"),
		playButton: require("play1.svg"),
		pauseButton: require("pause.svg"),
		location: {
		  host: window.location.host,
		  gameId: window.location.pathname.split("/")[2]
		}
	});
})();
