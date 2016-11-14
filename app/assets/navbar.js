(function () {
	'use strict';

    // Require index.html so it gets copied to dist
	require('./index.html');
	require('./styles/navbar.scss')

	const Elm = require('./elm/Navbar.elm');
	const mountNode = document.getElementById('main');

	Elm.Navbar.embed(mountNode);
})();
