{EventEmitter} = require 'events'

mongoose = require 'mongoose'

GeoSchema = new mongoose.Schema
  geometry:
    type: { type: String }
    coordinates: []
  created: { type: Date, default: Date.now }
  meta: {}
GeoSchema.index({ geometry: '2dsphere' });

docToGeo = (doc) ->
  geometry: doc.geometry
  meta: doc.meta
  created: doc.created

geoToDoc = (geo) ->
  geometry: geo.geometry
  meta: geo.meta

class MongoService extends EventEmitter
  constructor: (@db, collectionName) ->
    @Geo = @db.model collectionName, GeoSchema

  createGeo: (geo, callback) ->
    new @Geo(geoToDoc geo).save (err, doc) =>
      geo = docToGeo doc
      callback err, geo if callback?
      @emit 'new geo', geo if not err?

  createGeos: (geos, callback) ->
    result = []
    errs = undefined
    for geo in geos
      new @Geo(geoToDoc geo).save (err, doc) =>
        geo = result.push (if doc? then docToGeo doc else undefined)
        @emit 'new geo', geo if not err? and geo?
        (if errs? then errs.push(err) else errs = [err]) if err?
        callback(errs, result) if result.length is geos.length and callback?

  getGeo: (id, callback) ->
    @Geo.findById id, (err, doc) -> callback err, docToGeo doc

  getGeos: (opt, callback) ->
    {find, sort, limit} = opt if opt?
    q = @Geo.find find
    q = q.sort sort if sort?
    q = q.limit limit if limit?
    q.exec (err, docs) -> callback err, (docToGeo doc for doc in docs)

module.exports = (opt) ->
  if typeof opt is 'string'
    url = opt
  else
    {url, db, collectionName} = opt

  db ?= mongoose.connect url
  collectionName ?= 'geo'

  new MongoService db, collectionName
