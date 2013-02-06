exports.geoJsonToGeo = (geoJson) ->
  lnglat: geoJson.geometry.coordinates
  meta: geoJson.properties

exports.geoToGeoJson = geoToGeoJson = (geo) ->
  type: 'Feature'
  geometry:
    type: 'Point'
    coordinates: geo.lnglat
  properties: geo.meta

exports.geosToGeoJson = (geos) ->
  type: 'FeatureCollection'
  features: (geoToGeoJson geo for geo in geos)
