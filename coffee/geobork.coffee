service = require './service'
router = require './router'

#module.exports = (server, dbUrl) ->
#  srvc = service dbUrl or 'mongodb://localhost/geobork'
#  # Route HTTP requests to service layer
#  app = router.http srvc
#  server.on 'request', app
#  # Connect SocketIO to HTTP server
#  io = router.socketio srvc, server
#  # Forward new geos from service layer to sockets
#  #srvc.on 'new geo', (geo) -> io.sockets.emit 'new geo', geo
#  express: app
#  io: io

module.exports =
  mongoService: service
  controller: require './controller'
  router: router
  geojson: require './geojson'
