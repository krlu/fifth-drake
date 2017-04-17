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
		blueTowerKillIcon : require("Dashboard/blue_chess_piece_kill.svg"),
    redTowerKillIcon : require("Dashboard/red_chess_piece_kill.svg"),
    blueTowerIcon : require("Dashboard/blue_chess_piece.svg"),
    redTowerIcon : require("Dashboard/red_chess_piece.svg"),
    blueInhibitorKillIcon : require("Dashboard/blue_inhibitor_kill.svg"),
    redInhibitorKillIcon : require("Dashboard/red_inhibitor_kill.svg"),
    blueInhibitorIcon : require("Dashboard/blue_inhib.svg"),
    redInhibitorIcon : require("Dashboard/red_inhib.svg")
	});
})();
