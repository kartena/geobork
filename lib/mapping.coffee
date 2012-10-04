exports.geoJsonToDoc = (geoJson) ->
  loc: geoJson.geometry.coordinates
  meta: geoJson.properties.meta
  by: geoJson.properties.by

exports.docToGeoJson = docToGeoJson = (doc) ->
  type: 'Feature'
  geometry:
    type: 'Point'
    coordinates: doc.loc
  properties:
    meta: doc.meta
    created: doc.created
    by: doc.by

exports.docsToGeoJson = (docs) ->
  type: 'FeatureCollection'
  features: (docToGeoJson doc for doc in docs)
