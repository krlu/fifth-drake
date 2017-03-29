(function () {
	'use strict';

	require('elm-css/settings.css');

	const Elm = require('./Settings/Settings.elm');
	const mountNode = document.getElementById('Content');

	Elm.Settings.embed(mountNode, {
    searchIcon: require("Settings/ic_search_black_24px.svg"),
    addUserIcon: require("Settings/ic_add_black_24px.svg"),
    removeUserIcon : require("Dashboard/ic_clear_white_24px.svg"),
    updatePermissionIcon : require("Settings/ic_person_white_24px.svg")
	});
})();
