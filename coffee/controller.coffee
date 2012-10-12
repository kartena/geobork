{EventEmitter} = require 'events'
url = require 'url'
map = require './mapping'

class Controller extends EventEmitter
  constructor: (@srvc) ->
  # Put multiple geos
  newGeos: (docs, res, next) ->
    @srvc.createGeos docs, (errs, docs) =>
      return next(errs) if errs?
      #io.sockets.emit('new geo', map.docToGeo(doc)) for doc in docs
      @emit('new geo', map.docToGeo(doc)) for doc in docs
      res.end()

  # Put single/multi geos
  newGeo: (doc, res, next) ->
    @srvc.createGeo doc, (err, doc) =>
      return next(err) if err?
      #io.sockets.emit 'new geo', map.docToGeo(doc)
      @emit 'new geo', map.docToGeo(doc)
      res.end()

  oneOrMoreGeos: (json) ->
    if json instanceof Array
      @newGeos.bind @, (map.geoToDoc geo for geo in json)
    else
      @newGeo.bind @, map.geoToDoc(json)

  oneOrMoreGeoJson: (json) ->
    if json.type is 'FeatureCollection'
      @newGeos.bind @, (map.geoJsonToDoc geoJson for geoJson in json.features)
    else
      @newGeo.bind @, map.geoJsonToDoc(json)

  # Get geo by id
  idGeo: (convert, req, res, next) ->
    @srvc.getGeo req.params.id, (err, doc) ->
      return next(err) if err?
      res.json converter doc

  # Get multiple geos by query
  queryGeos: (convert, req, res, next) ->
    parts = url.parse req.url, true
    find = JSON.parse(parts.query.q) if parts.query.q?
    sort = JSON.parse(parts.query.sort) if parts.query.sort?
    @srvc.getGeos (err, geos) ->
      return next(err) if err?
      res.json convert geos
    ,{find, sort}

module.exports = Controller
