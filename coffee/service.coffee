mongoose = require 'mongoose'

GeoSchema = new mongoose.Schema
  type: String
  lnglats: []
  created: { type: Date, default: Date.now }
  meta: {}

module.exports = (opt) ->
  db = if opt.db? then opt.db else mongoose.connect opt.url
  Geo = db.model (opt.collectionName or 'Geo'), GeoSchema

  db: db
  createGeo: (geo, callback) ->
    new Geo(geoToDoc geo).save callback

  createGeos: (geos, callback) ->
    result = []
    errs = undefined
    for geo in geos
      new Geo(geoToDoc geo).save (err, doc) ->
        result.push (if doc? then docToGeo doc else undefined)
        (if errs? then errs.push(err) else errs = [err]) if err?
        callback(errs, result) if result.length is geos.length

  getGeo: (id, callback) ->
    Geo.findById id, (err, doc) -> callback err, docToGeo doc

  getGeos: (callback, opt) ->
    {find, sort, limit} = opt if opt?
    q = Geo.find find
    q = q.sort (if sort? then sort else 'created')
    if limit? then q = q.limit limit
    q.exec (err, docs) -> callback err, (docToGeo doc for doc in docs)

exports.docToGeo = docToGeo = (doc) ->
  type: doc.type
  lnglats: doc.lnglats
  meta: doc.meta
  created: doc.created

exports.geoToDoc = geoToDoc = (geo) ->
  type: geo.type
  lnglats: geo.lnglats
  meta: geo.meta
