(function () {
	'use strict';

	require('elm-css/settings.css');

	const Elm = require('./Settings/Settings.elm');
	const mountNode = document.getElementById('Content');

	Elm.Settings.embed(mountNode, {
    searchIcon: require("Settings/ic_search_black_24px.svg"),
    addUserIcon: require("Settings/ic_add_white_24px.svg")
	});
})();
