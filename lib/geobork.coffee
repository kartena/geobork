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

# Setup web server express+socket.io
app = express()
server = http.createServer app
io = require('socket.io').listen server

app.use express.bodyParser()

# TODO: move to configuration
app.use express.logger 'dev'
app.use express.static process.argv[3] or 'client'

app.use '/geo*', (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  next()
# end

app.put '/geo', (req, res, next) ->
  geoJson = req.body
  controller.createGeo map.geoJsonToDoc(geoJson), (err) ->
    return next(err) if err?
    io.sockets.emit 'new geo', geoJson
    res.end()

app.get '/geo_put', (req, res, next) ->
  parts = url.parse req.url, true
  if parts.query.json?
    doc = map.geoJsonToDoc JSON.parse parts.query.json
  else
    meta = {}
    meta[k] = cohers(v) for k, v of parts.query when not (k in ['lat','lng'])
    {lat, lng} = parts.query
    doc = { loc: [ parseFloat(lng), parseFloat(lat) ], meta }
  controller.createGeo doc, (err, doc) ->
    return next(err) if err?
    io.sockets.emit 'new geo', map.docToGeoJson(doc)
    res.end()

app.get '/geo/:id', (req, res, next) ->
  controller.getGeo req.params.id, (err, geo) ->
    return next(err) if err?
    res.end JSON.stringify map.docToGeoJson geo

app.get '/geo', (req, res, next) ->
  parts = url.parse req.url, true
  find = JSON.parse(parts.query.q) if parts.query.q?
  sort = JSON.parse(parts.query.sort) if parts.query.sort?
  controller.getGeos (err, geos) ->
    return next(err) if err?
    res.end JSON.stringify map.docsToGeoJson geos
  ,{find, sort}

io.sockets.on 'connection', (socket) ->
  socket.on 'new geo', (geoJson) ->
    controller.createGeo map.geoJsonToDoc(geoJson), (err, doc) ->
      socket.broadcast.emit 'new geo', map.docToGeoJson(doc)

server.listen parseInt(process.argv[2] or 8013)
process.on 'exit', -> server.close()
