http = require 'http'
express = require 'express'
controller = require './controller'
map = require './mapping'

collect = (req, callback) ->
  data = ''
  req.on 'data', (d) -> data += d
  req.on 'end', -> callback data

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

app.use '/geo/:id', (req, res, next) ->
  controller.getGeo req.params.id, (err, geo) ->
    return next(err) if err?
    res.end JSON.stringify map.docToGeoJson geo

app.use '/geo', (req, res, next) ->
  controller.getGeos (err, geos) ->
    return next(err) if err?
    res.end JSON.stringify map.docsToGeoJson geos

devices = {}

io.sockets.on 'connection', (socket) ->
  console.log 'new client connected'
  socket.on 'login', (ident) ->
    console.log 'client logging in'
    if devices[ident.deviceId]?
      socket.disconnect()
      return
    socket.set 'deviceId', ident.deviceId, ->
      io.sockets.emit 'new device', ident
      # Send all stored geos
      controller.getGeos (err, geos) ->
        socket.emit 'geos', map.docsToGeoJson geos
  socket.on 'new geo', (geoJson) ->
    console.log 'new geo from client!'
    socket.get 'deviceId', (err, deviceId) ->
      geoJson.properties.by = deviceId
      socket.broadcast.emit 'new geo', geoJson
      controller.createGeo map.geoJsonToDoc(geoJson)

server.listen 8013
process.on 'exit', -> server.close()
