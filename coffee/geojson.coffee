exports.toGeo = (geoJson) ->
  if geoJson.geometry.type is 'MultiLineString'
    throw 'Geometry type MultiLineString is not supported.'
  type: geoJson.geometry.type
  lnglats: geoJson.geometry.coordinates
  meta: geoJson.properties

exports.multiLineStringToGeos = (geoJson) ->
  for coordinates in geoJson.geometry.coordinates
    type: 'LineString'
    lnglats: coordinates
    meta: geoJson.properties

exports.fromGeo = fromGeo = (geo) ->
  type: 'Feature'
  geometry:
    type: geo.type or 'Point'
    coordinates: geo.lnglats
  properties: geo.meta

exports.fromGeos = (geos) ->
  type: 'FeatureCollection'
  features: (fromGeo geo for geo in geos)
