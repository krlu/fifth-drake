const path = require('path');
const assetPath = 'app/assets';
const srcPath = path.join(__dirname, assetPath);

module.exports = {
	entry: {
		app: [
			path.join(srcPath, "index.js")
		]
	},

	output: {
		path: path.resolve(__dirname, assetPath, 'build'),
		publicPath: '/static',
		filename: '[name].js'
	},

	resolve: {
		modulesDirectories: [
			'node_modules',
			'public'
		],
		extensions: ['', '.js', '.elm']
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
				test: /\.(jpe?g|png|gif|eot|woff|ttf|svg|woff2)$/,
				loader: "file?name=/[path][name].[ext]"
			}
		],
		noParse: /\.elm$/
	}
};
