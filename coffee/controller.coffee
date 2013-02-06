{EventEmitter} = require 'events'
url = require 'url'
map = require './mapping'

cohers = (v) ->
  return Number(v) if not Number.isNaN(Number v)
  return true if v is "true"
  return false if v is "false"
  return new Date(v) if not Number.isNaN(Date.parse v)
  return v

module.exports = (srvc) ->
  # Put multiple geos
  _newGeos = (docs, res, next) ->
    srvc.createGeos docs, (errs, docs) =>
      return next(errs) if errs?
      #io.sockets.emit('new geo', map.docToGeo(doc)) for doc in docs
      #@emit('new geo', map.docToGeo(doc)) for doc in docs
      res.end()

  # Put single/multi geos
  _newGeo = (doc, res, next) ->
    srvc.createGeo doc, (err, doc) =>
      return next(err) if err?
      #io.sockets.emit 'new geo', map.docToGeo(doc)
      #@emit 'new geo', map.docToGeo(doc)
      res.end()

  postGeos = (req, res, next) ->
    json = req.body
    (if json instanceof Array
      _newGeos.bind undefined, (map.geoToDoc geo for geo in json)
    else
      _newGeo.bind undefined, map.geoToDoc(json)
    ) res, next

  # Create geo using GET method, use parameter 'json'
  postGeosByGet = (req, res, next) ->
    req.body = JSON.parse url.parse(req.url, true).query.json
    createGeos req, res, next

  postGeoJson = (req, res, next) ->
    json = req.body
    (if json.type is 'FeatureCollection'
      _newGeos.bind undefined,
        (map.geoJsonToDoc geoJson for geoJson in json.features)
    else
      _newGeo.bind undefined, map.geoJsonToDoc(json)
    ) res, next

  # Create geo using GET method and GeoJson, use parameter 'json'
  postGeoJsonByGet = (req, res, next) ->
    req.body = JSON.parse url.parse(req.url, true).query.json
    createGeoJson req, res, next

  # Add geo by url parameters, 'lat' and 'lng' for the coordinate the rest of
  # the parameters are considered meta data.
  postGeoByGetParam = (req, res, next) ->
    parts = url.parse req.url, true
    meta = {}
    meta[k] = cohers(v) for k, v of parts.query when not (k in ['lat','lng'])
    {lat, lng} = parts.query
    _newGeo
      lnglat: [parseFloat(lng), parseFloat(lat)]
      meta: meta
    ,res, next

  # Get geo by id
  _idGeo = (convert, req, res, next) ->
    srvc.getGeo req.params.id, (err, doc) ->
      return next(err) if err?
      res.jsonp converter doc

  getGeo = _idGeo.bind undefined, map.docToGeo
  getGeoJson = _idGeo.bind undefined, map.docToGeoJson

  # Get multiple geos by query
  _queryGeos = (convert, req, res, next) ->
    parts = url.parse req.url, true
    find = JSON.parse(parts.query.q) if parts.query.q?
    sort = JSON.parse(parts.query.sort) if parts.query.sort?
    srvc.getGeos (err, geos) ->
      return next(err) if err?
      res.jsonp convert geos
    ,{find, sort}

  queryGeos = (req, res, next) ->
    _queryGeos ((docs) -> map.docToGeo doc for doc in docs) ,req, res, next
  queryGeoJson = _queryGeos.bind undefined, map.docsToGeoJson

  {
    postGeos, postGeoJson,
    postGeosByGet, postGeoJsonByGet, postGeoByGetParam,
    getGeo, getGeoJson,
    queryGeos, queryGeoJson
  }
