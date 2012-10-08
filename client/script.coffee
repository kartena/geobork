comparePosition = (p1, p2) ->
  return false if not p1? or not p2?
  {latitude:lat1, longitude:lng1} = p1.coords
  {latitude:lat2, longitude:lng2} = p2.coords
  return (lat1.toFixed(4) is lat2.toFixed(4) and
          lng1.toFixed(4) is lng2.toFixed(4))
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

deviceName = localStorage.getItem 'device-name'
$('#device-name').val deviceName if deviceName?

socket = io.connect '/'
socket.on 'new geo', (geoJson) ->
  console.log "Got geo from car.", geoJson
  addGeoms geoJson

login = (name) ->
  deviceName = name
  localStorage.setItem 'device-name', name
loggedIn = -> not not deviceName

cacheInterval = null
$('#start-position').click -> login $('#device-name').val()
$('#stop-position').click -> #clearInterval cacheInterval

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
        car: 'First car'
        name: deviceName
    lastSentPosition = position

getGeos = (query, callback) ->
  $.ajax
    type: 'GET'
    url: '/geo'
    data:
      q: JSON.stringify query
    success: (json, status, xhr) -> callback JSON.parse json

history = {}
addGeoms = (features) ->
  features = [features] if not (features instanceof Array)
  for f in features
    {geometry:{coordinates}, properties} = f
    line = (history[properties.name] or
            (history[properties.name] = L.polyline([]).addTo historyLayer))
    line.addLatLng new L.LatLng(coordinates[1], coordinates[0])
    line.lastFeature = f
  updateHistory()

updateHistory = ->
  for name, line of history
    latlngs = line.getLatLngs()
    lastLatLng = latlngs[latlngs.length-1]
    meta = line.lastFeature.properties
    if not line._point?
      icon = L.icon
        iconUrl: 'img/arrow.png'
        iconSize: [42, 42]
        iconAnchor: [21, 21]
        popupAnchor: [0, -25]
      line._point = L.marker(lastLatLng, {icon}).addTo historyLayer
    p = line._point
    p.setLatLng lastLatLng
    p.bindPopup "#{name}<br>#{meta._created}"
    p._heading = meta.heading or 45
  rotateIcons()

rotateIcons = ->
  historyLayer.eachLayer (layer) ->
    if layer._heading?
      icon = $(layer._icon)
      icon.css '-webkit-transform',
        "#{icon.css '-webkit-transform'} rotate(#{layer._heading}deg)"

map = L.map 'map'
L.tileLayer('http://{s}.tile.cloudmade.com/4e8589a3643448ff8f36c1def19fbd8c/997/256/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
  maxZoom: 18
}).addTo map
map.on 'zoomend', -> rotateIcons()

historyLayer = L.layerGroup().addTo map

geolocation (position) ->
  {latitude:lat, longitude:lng} = position.coords
  map.setView [lat, lng], 13

# Get all logged positions for the day
getFrom = new Date()
getFrom.setHours 0,0,0,0
getGeos {created: {$gt: getFrom}}, (geoJson) -> addGeoms geoJson.features

$('#start-position').removeClass('nodisplay') if location.hash is '#tracking'
