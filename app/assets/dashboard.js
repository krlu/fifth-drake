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
		editTagButton: require("Dashboard/ic_mode_edit_white_24px.svg"),
		loadingIcon : require("Dashboard/loading.gif"),
		airDragonIcon : require("Dashboard/air_dragon.png"),
		earthDragonIcon : require("Dashboard/earth_dragon.png"),
		fireDragonIcon : require("Dashboard/fire_dragon.png"),
		waterDragonIcon : require("Dashboard/water_dragon.png"),
		elderDragonIcon : require("Dashboard/elder_dragon.png"),
		towerKillIcon : require("Dashboard/grey_pawn.svg"),
    blueTowerIcon : require("Dashboard/blue_pawn.svg"),
    redTowerIcon : require("Dashboard/red_pawn.svg"),
    inhibitorKillIcon : require("Dashboard/grey_rook.svg"),
    blueInhibitorIcon : require("Dashboard/blue_rook.svg"),
    redInhibitorIcon : require("Dashboard/red_rook.svg")
	});
})();
