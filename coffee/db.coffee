schema = require './model'
db = require('mongoose').connect 'mongodb://localhost/geobork'
Geo = db.model 'Geo', schema.Geo

exports.createGeo = (geo, callback) ->
  new Geo(geo).save callback

exports.createGeos = (geos, callback) ->
  result = []
  errs = undefined
  for geo in geos
    new Geo(geo).save (err, doc) ->
      result.push doc or undefined
      (if errs? then errs.push(err) else errs = [err]) if err?
      callback(errs, result) if result.length is geos.length

exports.getGeo = (id, callback) ->
  Geo.findById id, callback

exports.getGeos = (callback, opt) ->
  {find, sort} = opt if opt?
  q = Geo.find find
  q = q.sort (if sort? then sort else 'created')
  q.exec callback
