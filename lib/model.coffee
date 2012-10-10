{Schema} = require 'mongoose'

exports.Geo = new Schema
  lnglat: [Number]
  created: { type: Date, default: Date.now }
  meta: {}
