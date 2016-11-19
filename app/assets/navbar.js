(function () {
	'use strict';

	require('./styles/Navbar/navbar.scss')

	const Elm = require('./Navbar/Navbar.elm');
	const mountNode = document.getElementById('navbar');

	Elm.Navbar.embed(mountNode);
})();
