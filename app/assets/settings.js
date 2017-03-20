(function () {
	'use strict';

	require('elm-css/settings.css');

	const Elm = require('./Settings/Settings.elm');
	const mountNode = document.getElementById('Content');

	Elm.Settings.embed(mountNode, {
	});
})();
