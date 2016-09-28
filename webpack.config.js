const path = require('path');

module.exports = {
	entry: {
		app: [
			"./src/index.js"
		]
	},

	output: {
		path: path.resolve(__dirname + '/build'),
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
					/elm_stuff/
				],
				loader: 'elm-webpack'
			},
		],
		noParse: /\.elm$/
	}
}
