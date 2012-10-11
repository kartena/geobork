#!/usr/bin/env node

var argPort = parseInt(process.argv[2]),
    argWebRoot = process.argv[3],
    geobork = require('geobork'),
    server = geobork({
      webRoot: argWebRoot,
      log: true
    });

server.listen(argPort || 8013);
process.on('exit', function () {
  server.close();
});
