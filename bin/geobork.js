#!/usr/bin/env node

var geobork = require('../lib/geobork')
  , argPort = parseInt(process.argv[2]) || 8013
  , argDbName = process.argv[3] || 'geobork'
  , argWebRoot = process.argv[4];

geobork({
    dbUrl: 'mongodb://localhost/'+argDbName
  , webRoot: argWebRoot
  , log: true
}).listen(argPort);
