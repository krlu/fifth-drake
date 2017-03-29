(function () {
	'use strict';

	require('elm-css/navbar.css');

	const Elm = require('./Navbar/Navbar.elm');
	const mountNode = document.getElementById('Navbar');

	Elm.Navbar.embed(mountNode, {
        homeIcon: require("Navbar/ic_home_white_24px.svg"),
        gamesIcon: require("Navbar/ic_games_white_24px.svg"),
        settingsIcon: require("Navbar/ic_settings_white_24px.svg"),
        problemIcon: require("Navbar/ic_report_problem_white_24px.svg"),
        logoutIcon: require("Navbar/ic_power_settings_new_white_24px.svg")
	});
})();
