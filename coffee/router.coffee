url = require 'url'
express = require 'express'

map = require './mapping'
Controller = require './controller'

cohers = (v) ->
  return Number(v) if not Number.isNaN(Number v)
  return true if v is "true"
  return false if v is "false"
  return new Date(v) if not Number.isNaN(Date.parse v)
  return v

resRouter = (getResHandler, req, res, next) -> getResHandler(req) res, next

exports.http = (ctrl, app) ->
  app ?= express()
  # Setup web server
  app.use express.bodyParser()

  app.put '/geo', resRouter.bind undefined, (req) ->
    ctrl.oneOrMoreGeos req.body
  app.put '/geojson', resRouter.bind undefined, (req) ->
    ctrl.oneOrMoreGeoJson req.body

  # Put using GET
  app.get '/put_geo', resRouter.bind undefined, (req) ->
    ctrl.oneOrMoreGeos JSON.parse url.parse(req.url, true).json
  app.get '/put_geojson', resRouter.bind undefined, (req) ->
    ctrl.oneOrMoreGeoJson JSON.parse url.parse(req.url, true).json
  app.get '/put_params', resRouter.bind undefined, (req) ->
    parts = url.parse req.url, true
    meta = {}
    meta[k] = cohers(v) for k, v of parts.query when not (k in ['lat','lng'])
    {lat, lng} = parts.query
    ctrl.newGeo.bind ctrl,
      lnglat: [parseFloat(lng), parseFloat(lat)]
      meta: meta

  # Get geo by id
  app.get '/geo/:id', ctrl.idGeo.bind ctrl, map.docToGeo
  app.get '/geojson/:id', ctrl.idGeo.bind ctrl, map.docToGeoJson

  # Get multiple geos by query
  app.get '/geo', ctrl.queryGeos.bind ctrl, (docs) ->
    map.docToGeo doc for doc in docs
  app.get '/geojson', ctrl.queryGeos.bind ctrl, map.docsToGeoJson
  return app

exports.socketio = (srvc, server) ->
  # Socket.io setup
  io = require('socket.io').listen server

  io.sockets.on 'connection', (socket) ->
    socket.on 'new geo', (geo) ->
      srvc.createGeo map.geoToDoc(geo), (err, doc) ->
        socket.broadcast.emit 'new geo', map.docToGeo(doc)
  return io
