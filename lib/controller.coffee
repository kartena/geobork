mongoose = require 'mongoose'
model = require './model'
Geo = mongoose.model 'Geo'
db = mongoose.connect 'mongodb://localhost/test'

exports.createGeo = (geo, callback) ->
  new Geo(geo).save callback

exports.getGeo = (id, callback) ->
  Geo.findById id, callback

exports.getGeos = (max, callback) ->
  Geo.where().sort('created', -1).limit(max).run callback

