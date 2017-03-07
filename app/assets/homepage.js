(function () {
	'use strict';

	require('elm-css/homepage.css');

	const Elm = require('./Homepage/Homepage.elm');
	const mountNode = document.getElementById('Content');

	Elm.Homepage.embed(mountNode, {
  });
})();
