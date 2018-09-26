const path = require("path");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

const isProduction = process.env.NODE_ENV === 'production';
const debug = false;

module.exports = {
  entry: {
    app: [ './src/index.js' ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js',
  },

  module: {
    rules: [
      {
        test: /\.(css|scss)$/,
        use: [ 'style-loader', 'css-loader', ]
      },
      {
        test:    /\.html$/,
        exclude: /node_modules/,
        loader:  'file-loader?name=[name].[ext]',
      },
      {
        test:    /\.elm$/,
        exclude: [ /elm-stuff/, /node_modules/ ],
        loader:  'elm-webpack-loader?verbose=true&warn=true&debug=' + debug,
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff',
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader',
      },
    ],

    noParse: /\.elm$/
  },

  plugins: !isProduction ? [] : [
    /**
     * For configuration, see: https://github.com/webpack-contrib/uglifyjs-webpack-plugin
     *
     * Uglification gives us an average reduction of 40% in file size.
     */
    new UglifyJsPlugin({
      test: /\.js$/,
      include: /\.js$/,
      sourceMap: true,
      uglifyOptions: {
        compress: {
          pure_funcs: [ 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9' ]
        }
      }
    })
  ],

  devtool: 'source-map',

  devServer: {
    inline: true,
    stats: { colors: true },
    host: '0.0.0.0',
    port: 4201,
    disableHostCheck: true
  },
};

/* vim: set ts=2 sw=2 et: */
