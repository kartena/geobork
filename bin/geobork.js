#!/usr/bin/env node

var express = require('express'),
    geobork = require('../lib/geobork'),

    argPort = parseInt(process.argv[2]),
    argDbName = process.argv[3] || 'geobork',
    argWebRoot = process.argv[4],

    server = require('http').createServer(),
    app, io;

servers = geobork(server, 'mongodb://localhost/'+argDbName);

// configuration
servers.express.use(express.logger('dev'));
if (argWebRoot) servers.express.use(express.static(argWebRoot));

servers.express.use('/geo*', function (req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'X-Requested-With');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
  next();
});
// end config

server.listen(argPort || 8013);

process.on('exit', function () {
  server.close();
});
