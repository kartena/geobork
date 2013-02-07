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
  _newGeos = (geos, res, next) ->
    srvc.createGeos geos, (errs, geos) =>
      return next(errs) if errs?
      #io.sockets.emit('new geo', map.docToGeo(doc)) for doc in docs
      #@emit('new geo', map.docToGeo(doc)) for doc in docs
      res.end()

  # Put single/multi geos
  _newGeo = (geo, res, next) ->
    srvc.createGeo geo, (err, geo) =>
      return next(err) if err?
      #io.sockets.emit 'new geo', map.docToGeo(doc)
      #@emit 'new geo', map.docToGeo(doc)
      res.end()

  postGeos = (req, res, next) ->
    json = req.body
    (if json instanceof Array
      _newGeos.bind undefined, json
    else
      _newGeo.bind undefined, json
    ) res, next

  # Create geo using GET method, use parameter 'json'
  postGeosByGet = (req, res, next) ->
    req.body = JSON.parse url.parse(req.url, true).query.json
    createGeos req, res, next

  postGeoJson = (req, res, next) ->
    json = req.body
    (if json.type is 'FeatureCollection'
      _newGeos.bind undefined,
        (map.geoJsonToGeo geoJson for geoJson in json.features)
    else
      _newGeo.bind undefined, map.geoJsonToGeo(json)
    ) res, next

  # Create geo using GET method and GeoJson, use parameter 'json'
  postGeoJsonByGet = (req, res, next) ->
    req.body = JSON.parse url.parse(req.url, true).query.json
    postGeoJson req, res, next

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
    srvc.getGeo req.params.id, (err, geo) ->
      return next(err) if err?
      res.jsonp convert geo

  getGeo = _idGeo.bind undefined, (x) -> x
  getGeoJson = _idGeo.bind undefined, map.geoToGeoJson

  # Get multiple geos by query
  _queryGeos = (convert, req, res, next) ->
    parts = url.parse req.url, true
    find = JSON.parse(parts.query.q) if parts.query.q?
    sort = JSON.parse(parts.query.sort) if parts.query.sort?
    limit = parseInt(parts.query.limit) if parts.query.limit?
    srvc.getGeos (err, geos) ->
      return next(err) if err?
      res.jsonp convert geos
    ,{find, sort, limit}

  queryGeos = _queryGeos.bind undefined, (x) -> x
  queryGeoJson = _queryGeos.bind undefined, map.geosToGeoJson

  {
    postGeos, postGeoJson,
    postGeosByGet, postGeoJsonByGet, postGeoByGetParam,
    getGeo, getGeoJson,
    queryGeos, queryGeoJson
  }
