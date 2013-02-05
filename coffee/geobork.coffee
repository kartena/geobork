service = require './service'
router = require './router'
Controller = require './controller'

module.exports = (server, dbUrl) ->
  srvc = service dbUrl or 'mongodb://localhost/geobork'
  ctrl = new Controller srvc
  app = router.http ctrl
  server.on 'request', app
  io = router.socketio srvc, server
  # Forward new geos from http to sockets
  ctrl.on 'new geo', (geo) -> io.sockets.emit 'new geo', geo
  express: app
  io: io
  webController: ctrl

