mongoose = require 'mongoose'
Schema = mongoose.Schema

mongoose.model('Geo', new Schema(
  loc: [Number]
  created: { type: Date, default: Date.now }
  meta: {}
))
