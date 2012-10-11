http = require 'http'
url = require 'url'
express = require 'express'

controller = require './controller'
map = require './mapping'

cohers = (v) ->
  return Number(v) if not Number.isNaN(Number v)
  return true if v is "true"
  return false if v is "false"
  return new Date(v) if not Number.isNaN(Date.parse v)
  return v

module.exports = (opt) ->
  # Setup web server express+socket.io
  app = express()
  server = http.createServer app
  io = require('socket.io').listen server

  app.use express.bodyParser()

  # TODO: move to configuration
  app.use express.logger 'dev' if opt.log
  app.use express.static opt.webRoot if opt.webRoot?

  app.use '/geo*', (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
    next()
  # end

  newGeo = (getDoc, req, res, next) ->
    controller.createGeo getDoc(req), (err, doc) ->
      return next(err) if err?
      io.sockets.emit 'new geo', map.docToGeo(doc)
      res.end()
  app.put '/geo', newGeo.bind undefined, (req) -> map.geoToDoc req.body
  app.put '/geojson', newGeo.bind undefined, (req) -> map.geoJsonToDoc req.body
  app.get '/put_geo', newGeo.bind undefined, (req) ->
    parts = url.parse req.url, true
    map.geoToDoc JSON.parse parts.query.json
  app.get '/put_geojson', newGeo.bind undefined, (req) ->
    parts = url.parse req.url, true
    map.geoJsonToDoc JSON.parse parts.query.json
  app.get '/put_params', newGeo.bind undefined, (req) ->
    parts = url.parse req.url, true
    meta = {}
    meta[k] = cohers(v) for k, v of parts.query when not (k in ['lat','lng'])
    { lat, lng } = parts.query
    { lnglat: [ parseFloat(lng), parseFloat(lat) ], meta }

  idGeo = (convert, req, res, next) ->
    controller.getGeo req.params.id, (err, doc) ->
      return next(err) if err?
      res.json converter doc
  app.get '/geo/:id', idGeo.bind undefined, map.docToGeo
  app.get '/geojson/:id', idGeo.bind undefined, map.docToGeoJson

  queryGeos = (convert, req, res, next) ->
    parts = url.parse req.url, true
    find = JSON.parse(parts.query.q) if parts.query.q?
    sort = JSON.parse(parts.query.sort) if parts.query.sort?
    controller.getGeos (err, geos) ->
      return next(err) if err?
      res.json convert geos
    ,{find, sort}
  app.get '/geo', queryGeos.bind undefined, (docs) ->
    map.docToGeo doc for doc in docs
  app.get '/geojson', queryGeos.bind undefined, map.docsToGeoJson

  io.sockets.on 'connection', (socket) ->
    socket.on 'new geo', (geo) ->
      controller.createGeo map.geoToDoc(geo), (err, doc) ->
        socket.broadcast.emit 'new geo', map.docToGeo(doc)

  return server
