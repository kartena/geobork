#!/usr/bin/env node

var express = require('express'),
    geobork = require('../lib/geobork'),

    argPort = parseInt(process.argv[2]),
    argDbName = process.argv[3] || 'geobork',
    argWebRoot = process.argv[4],

    srvc, app;

srvc = geobork.mongoService('mongodb://localhost/'+argDbName);
app = geobork.router.http(srvc);

// configuration
app.use(express.logger('dev'));
if (argWebRoot) app.use(express.static(argWebRoot));

app.use('/geo*', function (req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'X-Requested-With');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
  next();
});
// end config

app.listen(argPort || 8013);

process.on('exit', function () {
  server.close();
});
