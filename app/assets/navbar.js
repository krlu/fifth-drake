(function () {
	'use strict';

	require('elm-css/navbar.css');

	const Elm = require('./Navbar/Navbar.elm');
	const mountNode = document.getElementById('navbar');

	Elm.Navbar.embed(mountNode);
})();
