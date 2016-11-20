(function () {
	'use strict';

	require('elm-css/navbar.css');

	const Elm = require('./Navbar/Navbar.elm');
	const mountNode = document.getElementById('Navbar');

	Elm.Navbar.embed(mountNode);
})();
