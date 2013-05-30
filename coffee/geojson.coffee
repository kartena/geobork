exports.toGeo = (geoJson) ->
  if geoJson.geometry.type is 'MultiLineString'
    throw 'Geometry type MultiLineString is not supported.'
  geometry: geoJson.geometry
  meta: geoJson.properties

exports.multiLineStringToGeos = (geoJson) ->
  for coordinates in geoJson.geometry.coordinates
    geometry:
      type: 'LineString'
      coordinates: coordinates
    meta: geoJson.properties

exports.fromGeo = fromGeo = (geo) ->
  type: 'Feature'
  geometry: geo.geometry
  properties: geo.meta

exports.fromGeos = (geos) ->
  type: 'FeatureCollection'
  features: (fromGeo geo for geo in geos)
