express = require('express')
controller = require './lib/controller'
map = require './lib/mapping'

collect = (req, callback) ->
  data = ''
  req.on 'data', (d) -> data += d
  req.on 'end', -> callback data

app = express.createServer()

app.use express.bodyParser()
app.use express.methodOverride()

# todo: move to configuration
app.use app.router
app.use express.static "#{__dirname}/client"

app.get '/geo*', (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  next()
# end

app.put '/geo', (req, res, next) ->
  controller.createGeo map.geoJsonToDoc(req.body), (err) ->
    if err? then next(err) else res.end()

app.get '/geo/:id', (req, res, next) ->
  controller.getGeo req.params.id, (err, geo) ->
    if err? then next(err) else res.end JSON.stringify map.docToGeoJson geo

app.get '/geo', (req, res, next) ->
  controller.getGeos 3, (err, geos) ->
    if err? then next(err) else res.end JSON.stringify map.docsToGeoJson geos

app.listen 8000
console.log(
  "Geo Borker is listening on port %d, log on to http://127.0.0.1:8000",
  app.address().port)
