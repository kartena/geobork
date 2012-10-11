exports.geoJsonToDoc = (geoJson) ->
  lnglat: geoJson.geometry.coordinates
  meta: geoJson.properties

exports.docToGeoJson = docToGeoJson = (doc) ->
  doc.meta._created = doc.created
  type: 'Feature'
  geometry:
    type: 'Point'
    coordinates: doc.lnglat
  properties: doc.meta

exports.docsToGeoJson = (docs) ->
  type: 'FeatureCollection'
  features: (docToGeoJson doc for doc in docs)

exports.docToGeo = (doc) ->
  lnglat: doc.lnglat
  meta: doc.meta
  created: doc.created

exports.geoToDoc = (geo) ->
  lnglat: geo.lnglat
  meta: geo.meta
