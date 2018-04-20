const path = require("path");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

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
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack-loader?verbose=true&warn=true',
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

  plugins: [
    /**
     * For configuration, see: https://github.com/webpack-contrib/uglifyjs-webpack-plugin
     *
     * Uglification when unbundled (firebase sources are loaded in <script> tags) gives us:
     * - firebase.js      416366
     * - firebase-auth.js 144225
     * - app.js           792084 -> 323247
     * Result:           1352675 -> 883838 = reduction of 35 %
     *
     * Uglification when bundled (firebase sources are loaded in app.js) gives us:
     * - app.js          1914087 -> 752640 = reduction of 61 %
     *
     * Note that bundling increases the un-uglified size.
     * Unbundled -> Bundled and uglified
     *   1352675 -> 752640 = reduction of 44 %
     */
    new UglifyJsPlugin({
      test: /\.js$/,
      include: /\.js$/,
      uglifyOptions: {
        compress: {
          pure_funcs: [ 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9' ]
        }
      }
    })
  ],

  devServer: {
    inline: true,
    stats: { colors: true },
    host: '0.0.0.0',
    port: 4201,
    disableHostCheck: true
  },
};
