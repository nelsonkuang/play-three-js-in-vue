'use strict'
const CopyWebpackPlugin = require('copy-webpack-plugin')
module.exports = {
  /**
   * You will need to set publicPath if you plan to deploy your site under a sub path,
   * for example GitHub Pages. If you plan to deploy your site to https://foo.github.io/bar/,
   * then publicPath should be set to "/bar/".
   * In most cases please use '/' !!!
   * Detail: https://cli.vuejs.org/config/#publicpath
   */
  publicPath: '', // The value can also be set to an empty string ('') or a relative path (./) so that all assets are linked using relative paths.
  outputDir: 'dist',
  assetsDir: 'static',
  productionSourceMap: false,
  configureWebpack: {
    plugins: [
      // 复制到自定义静态源
      new CopyWebpackPlugin(
        {
          patterns: [
            {
              // 来自那里(可以是对象，可以是String)
              from: './static/',
              // 走向那里(可以是对象，可以是String)
              to: 'static'
            }]
        }
      )
    ]
  },
  chainWebpack: config => {
    config.module
      .rule('glsl')
      .test(/\.glsl$/)
      .use('raw-loader')
      .loader('raw-loader')
      .end()
  }
}