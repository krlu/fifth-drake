(function () {
	'use strict';

	require('elm-css/dashboard.css');

	const Elm = require('./Dashboard/Dashboard.elm');
	const mountNode = document.getElementById('Content');

	Elm.Dashboard.embed(mountNode, {
		minimapBackground: require("Dashboard/map.jpg"),
		playButton: require("Dashboard/ic_play_arrow_white_24px.svg"),
		pauseButton: require("Dashboard/ic_pause_white_24px.svg"),
		addTagButton: require("Dashboard/ic_add_white_48px.svg"),
		deleteTagButton: require("Dashboard/ic_clear_white_24px.svg"),
		loadingIcon : require("Dashboard/loading.gif")
	});
})();
