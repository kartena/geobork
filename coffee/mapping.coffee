exports.geoJsonToGeo = (geoJson) ->
  if geoJson.geometry.type is 'MultiLineString'
    throw 'Geometry type MultiLineString is not supported.'
  type: geoJson.geometry.type
  lnglats: geoJson.geometry.coordinates
  meta: geoJson.properties

exports.geoJsonMultiLineStringToGeos = (geoJson) ->
  for coordinates in geoJson.geometry.coordinates
    type: 'LineString'
    lnglats: coordinates
    meta: geoJson.properties

exports.geoToGeoJson = geoToGeoJson = (geo) ->
  type: 'Feature'
  geometry:
    type: geo.type or 'Point'
    coordinates: geo.lnglats
  properties: geo.meta

exports.geosToGeoJson = (geos) ->
  type: 'FeatureCollection'
  features: (geoToGeoJson geo for geo in geos)
