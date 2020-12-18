const path = require('path');

// extract CSS as separate files
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

// gzip compiled files
const CompressionPlugin = require('compression-webpack-plugin');

module.exports = {
  entry: path.resolve(__dirname, 'assets', 'index.js'),
  mode: process.env.NODE_ENV,
  output: {
    path: path.resolve(__dirname, 'public'),
  },
  mode: process.env.NODE_ENV,
  module: {
    rules: [
      {
        test: /\.css$/,
        exclude: /node_modules/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: 'css-loader',
            options: {
              importLoaders: 1,
            }
          },
          {
            loader: 'postcss-loader'
          }
        ]
      },
      {
        test: /\.(png|woff|woff2|eot|ttf|svg)$/,
        loader: 'url-loader',
        options: {
          limit: 100000
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin(),
    new CompressionPlugin(),
  ],
}
