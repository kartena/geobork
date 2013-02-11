controller = require './controller'

exports.http = (srvc, app) ->
  express = require 'express'
  ctrl = controller srvc

  # Setup web server
  app ?= express()
  app.use express.bodyParser()

  # Create geo
  app.post '/geo', ctrl.postGeos
  app.post '/geojson', ctrl.postGeoJson

  # Create geo using GET
  app.get '/post_geo', ctrl.postGeosByGet
  app.get '/post_geojson', ctrl.postGeoJsonByGet
  app.get '/post_params', ctrl.postGeoByGetParam

  # Get geo by id
  app.get '/geo/:id', ctrl.getGeo
  app.get '/geojson/:id', ctrl.getGeoJson

  # Get multiple geos by query
  app.get '/geo', ctrl.queryGeos
  app.get '/geojson', ctrl.queryGeoJson
  return app

exports.socketio = (srvc, server) ->
  # Socket.io setup
  io = require('socket.io').listen server

  io.sockets.on 'connection', (socket) ->
    socket.on 'new geo', (geo) ->
      srvc.createGeo geo, (err, geo) ->
        socket.broadcast.emit 'new geo', geo
  return io
