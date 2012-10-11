#!/usr/bin/env node

var express = require('express'),
    geobork = require('../lib/geobork'),

    argPort = parseInt(process.argv[2]),
    argWebRoot = process.argv[3],

    server = require('http').createServer(),
    app, io;

app = geobork.http(server);
io = geobork.socketio(server);

// Forward new geos from http to sockets
app.controller.on('new geo', function (json) {
  io.sockets.emit('new geo', json);
});

// configuration
app.use(express.logger('dev'));
if (argWebRoot) app.use(express.static(argWebRoot));

app.use('/geo*', function (req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'X-Requested-With');
  next();
});
// end config

server.listen(argPort || 8013);

process.on('exit', function () {
  server.close();
});
