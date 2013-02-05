schema = require './model'
mongoose = require 'mongoose'

module.exports = (url) ->
  db = mongoose.connect url
  Geo = db.model 'Geo', schema.Geo

  createGeo: (geo, callback) ->
    new Geo(geo).save callback
  createGeos: (geos, callback) ->
    result = []
    errs = undefined
    for geo in geos
      new Geo(geo).save (err, doc) ->
        result.push doc or undefined
        (if errs? then errs.push(err) else errs = [err]) if err?
        callback(errs, result) if result.length is geos.length
  getGeo: (id, callback) ->
    Geo.findById id, callback
  getGeos: (callback, opt) ->
    {find, sort} = opt if opt?
    q = Geo.find find
    q = q.sort (if sort? then sort else 'created')
    q.exec callback
