(function () {
	'use strict';

	require('elm-css/homepage.css');

	const Elm = require('./Homepage/Homepage.elm');
	const mountNode = document.getElementById('Content');

	Elm.Homepage.embed(mountNode, {
			upArrow: require("Homepage/ic_arrow_upward_black_24px.svg"),
			downArrow: require("Homepage/ic_arrow_downward_black_24px.svg")
  });
})();
