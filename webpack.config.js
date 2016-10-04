const path = require('path');

module.exports = {
	entry: {
		app: [
			"./src/index.js"
		]
	},

	output: {
		path: path.resolve(__dirname, '/build'),
		filename: '[name].js',
	},

	resolve: {
		modulesDirectories: [
			'node_modules',
			path.resolve(__dirname, './node_modules')
		],
		extensions: ['', '.js', 'elm']
	},

	devtool: "source-map",

	module: {
		preLoaders: [
			{
				test: /\.js$/,
				loader: "source-map-loader"
			}
		],
		loaders: [
			{
				test: /\.(css|scss)$/,
				loaders: [
					'style',
					'css?sourceMap',
					'sass?sourceMap'
				]
			},
			{
				test: /\.html$/,
				exclude: /node_modules/,
				loader: 'file?name=[name].[ext]'
			},
			{
				test: /\.elm$/,
				exclude: [
					/node_modules/,
					/elm_stuff/,
					/src\/elm\/Stylesheets.elm/
				],
				loader: 'elm-webpack'
			},
			{
				test: /\.(jpe?g|png|gif|svg|eot|woff|ttf|svg|woff2)$/,
				loader: "file?name=[name].[ext]"
			}
		],
		noParse: /\.elm$/
	}
}
