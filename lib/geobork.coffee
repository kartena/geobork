http = require 'http'
url = require 'url'
express = require 'express'

controller = require './controller'
map = require './mapping'

# Setup web server express+socket.io
app = express()
server = http.createServer app
io = require('socket.io').listen server

app.use express.bodyParser()

# TODO: move to configuration
app.use express.logger 'dev'
app.use express.static 'client'

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

app.get '/geo_put*', (req, res, next) ->
  parts = url.parse req.url, true
  {lat, lng} = parts.query
  delete parts.query.lat
  delete parts.query.lng
  doc = {loc:[lng, lat], meta:parts.query}
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
  query = JSON.parse(parts.query.q) if parts.query.q?
  controller.getGeos query, (err, geos) ->
    return next(err) if err?
    res.end JSON.stringify map.docsToGeoJson geos

io.sockets.on 'connection', (socket) ->
  socket.on 'new geo', (geoJson) ->
    controller.createGeo map.geoJsonToDoc(geoJson), (err, doc) ->
      socket.broadcast.emit 'new geo', map.docToGeoJson(doc)

server.listen 8013
process.on 'exit', -> server.close()
