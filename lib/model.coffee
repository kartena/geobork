{Schema} = require 'mongoose'

exports.Geo = new Schema
  loc: [Number]
  created: { type: Date, default: Date.now }
  meta: {}
  by: String

exports.Ident = new Schema
  deviceId: String
  name: String
