schema = require './model'
db = require('mongoose').connect 'mongodb://localhost/geobork'
Geo = db.model 'Geo', schema.Geo

exports.createGeo = (geo, callback) ->
  new Geo(geo).save callback

exports.getGeo = (id, callback) ->
  Geo.findById id, callback

exports.getGeos = (q, callback) ->
  Geo.find(q).sort({created: 1}).exec callback
