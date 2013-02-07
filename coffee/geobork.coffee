service = require './service'
router = require './router'

# Modules to export as geobork properties
pub =
  mongoService: service
  controller: require './controller'
  router: router
  geojson: require './geojson'

module.exports = (opt) ->
  express = require 'express'
  srvc = service opt.dbUrl
  app = router.http srvc

  if opt.log then app.use express.logger 'dev'
  if opt.webRoot? then app.use express.static opt.webRoot

  # Allow CORS
  app.use '/geo*', (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    next()
  #io = router.socketio srvc, server
  ## Forward new geos from service layer to sockets
  ##srvc.on 'new geo', (geo) -> io.sockets.emit 'new geo', geo

module.exports[k] = v for k, v of pub
