const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');
const assetPath = 'app/assets';
const srcPath = path.join(__dirname, assetPath);
const elmStylePaths = /Stylesheets.elm/;
const buildPath = path.resolve(__dirname, assetPath, 'build');

module.exports = {
	entry: {
		dashboard: [
			path.join(srcPath, "dashboard.js")
		],
		navbar: [
		path.join(srcPath, "navbar.js")
		]
	},

	output: {
		path: buildPath,
		publicPath: '/static',
		filename: '[name].js'
	},

	resolve: {
		root: srcPath,
		modulesDirectories: [
			'node_modules',
			'public'
		],
		extensions: ['', '.js', '.elm']
	},

	devtool: "source-map",

	noParse: /.elm$/,

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
				loader: 'html'
			},
			{
				test: /\.elm$/,
				exclude: [
					/node_modules/,
					/elm_stuff/,
					elmStylePaths
				],
				loader: 'elm-webpack'
			},
			{
				test: /\.(jpe?g|png|gif|eot|woff|ttf|svg|woff2)$/,
				loader: "file?name=/[path][name].[ext]"
			}
		],
		noParse: /\.elm$/
	},

	plugins: [
	    new CopyWebpackPlugin([
            { from: "public/champion/*", to: buildPath }
        ])
    ],

	devServer: {
		port: 3000,
        outputPath: buildPath,
		contentBase: path.join(__dirname, "public/"),
		historyApiFallback: {
			index: 'index.html',
			rewrites: [
				{ from: /game\/elm-css\/index\.css/, to: '/elm-css/index.css'}
			]
		},
		proxy: [
			{
				context: ['/game/**/data', '/game/**/tags'],
				target: 'http://localhost:4000'
            }
		]
	}
};
