comparePosition = (p1, p2) ->
  return false if not p1? or not p2?
  {latitude:lat1, longitude:lng1} = p1.coords
  {latitude:lat2, longitude:lng2} = p2.coords
  return (lat1.toFixed(3) is lat2.toFixed(3) and
          lng1.toFixed(3) is lng2.toFixed(3))
onPosition = ->
_geolocation = (callback) ->
  navigator.geolocation.getCurrentPosition callback, (err) ->
    console.error "Error when retrieving location '#{err.message}'."
geolocation = (callback) ->
  if lastPosition? then callback lastPosition else _geolocation callback
cachePosition = ->
  _geolocation (position) ->
    lastPosition = position
    onPosition(position)

deviceId = localStorage.getItem 'device-id'
if deviceId?
  deviceName = localStorage.getItem 'device-name'
  $('#device-name').val deviceName

geos = {}
devices = {}
loggedIn = -> return devices[deviceId]?
addGeo = (geo) ->
  dId = geo.properties.by
  geos[dId] = [] if not geos[dId]?
  geos[dId].push geo
  L.marker(geo.geometry.coordinates.reverse()).addTo map
addGeos = (geos_) ->
  geos_ = [geos_] if not (geos_ instanceof Array)
  addGeo(g) for g in geos_

socket = io.connect '/'
socket.on 'geos', (geoJson) ->
  console.log "Got geos.", geoJson
  addGeos geoJson.features
socket.on 'new geo', (geoJson) ->
  console.log "Got geo from car.", geoJson
  addGeos geoJson
socket.on 'new device', (ident) ->
  console.log "Got ident.", ident
  devices[ident.deviceId] = ident.name

login = (name) ->
  if not deviceId?
    deviceId = "#{Math.random() * 1e10}"
    localStorage.setItem 'device-id', deviceId
  localStorage.setItem 'device-name', name
  socket.emit 'login', {deviceId, name}

cacheInterval = null
$('#start-position').click -> login $('#device-name').val()
$('#stop-position').click -> clearInterval cacheInterval

# Start position tracking
cachePosition()
cacheInterval = setInterval cachePosition, 5000

lastSentPosition = null
onPosition = (position) ->
  if loggedIn() and not comparePosition(lastSentPosition, position)
    {latitude:lat, longitude:lng} = position.coords
    socket.emit 'new geo',
      geometry:
        type: 'Point'
        coordinates: [lng, lat]
      properties:
        meta:
          car: 'First car'
    lastSentPosition = position

map = L.map 'map'
L.tileLayer('http://{s}.tile.cloudmade.com/4e8589a3643448ff8f36c1def19fbd8c/997/256/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
  maxZoom: 18
}).addTo map

geolocation (position) ->
  {latitude:lat, longitude:lng} = position.coords
  map.setView [lat, lng], 13
  marker = L.marker([lat, lng]).addTo map
