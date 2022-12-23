const webpack = require('webpack');

module.exports = {
  configureWebpack: {
    module: {
      rules: [
        {
          resourceQuery: /raw/,
          type: 'asset/source',
        }
      ],
    },
    plugins: [
      new webpack.ProvidePlugin({
        Buffer: ['buffer', 'Buffer'],
      }),
      /*
      new webpack.ProvidePlugin({
             process: 'process/browser',
      }),
      */
    ],
    resolve: {
      fallback: {
        "buffer": require.resolve('buffer/'),
        "http": 'agent-base',
        "https": 'agent-base',
        "fs": false,
        "path": false,
        "stream": false,
        "crypto": false,
        "os": false,
        "url": false,
        "assert": false,
      }
    }
  }
};
