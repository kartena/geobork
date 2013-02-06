mongoose = require 'mongoose'

schema = require './model'

module.exports = (url) ->
  db = mongoose.connect url
  Geo = db.model 'Geo', schema.Geo

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
    {find, sort} = opt if opt?
    q = Geo.find find
    q = q.sort (if sort? then sort else 'created')
    q.exec (err, docs) -> callback err, (docToGeo doc for doc in docs)

exports.docToGeo = docToGeo = (doc) ->
  lnglat: doc.lnglat
  meta: doc.meta
  created: doc.created

exports.geoToDoc = geoToDoc = (geo) ->
  lnglat: geo.lnglat
  meta: geo.meta
