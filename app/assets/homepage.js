(function () {
	'use strict';

	require('elm-css/dashboard.css');

	const Elm = require('./Homepage/Homepage.elm');
	const mountNode = document.getElementById('Content');

	Elm.Homepage.embed(mountNode, {
  	});
})();
