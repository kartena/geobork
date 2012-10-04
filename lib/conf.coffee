config = {}

exports = (conf) ->
  config[k] = v for k,v of conf
  config
