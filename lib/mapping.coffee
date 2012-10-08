exports.geoJsonToDoc = (geoJson) ->
  loc: geoJson.geometry.coordinates
  meta: geoJson.properties

exports.docToGeoJson = docToGeoJson = (doc) ->
  doc.meta._created = doc.created
  type: 'Feature'
  geometry:
    type: 'Point'
    coordinates: doc.loc
  properties: doc.meta

exports.docsToGeoJson = (docs) ->
  type: 'FeatureCollection'
  features: (docToGeoJson doc for doc in docs)
