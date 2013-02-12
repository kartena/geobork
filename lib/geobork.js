// Generated by CoffeeScript 1.4.0
(function() {
  var k, pub, router, service, v;

  service = require('./service');

  router = require('./router');

  pub = {
    mongoService: service,
    controller: require('./controller'),
    router: router,
    geojson: require('./geojson')
  };

  module.exports = function(opt) {
    var app, express, srvc;
    express = require('express');
    srvc = service(opt.dbUrl);
    app = router.http(srvc);
    if (opt.log) {
      app.use(express.logger('dev'));
    }
    if (opt.webRoot != null) {
      app.use(express["static"](opt.webRoot));
    }
    return app.use('/geo*', function(req, res, next) {
      res.header('Access-Control-Allow-Origin', '*');
      res.header('Access-Control-Allow-Headers', 'X-Requested-With');
      res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
      return next();
    });
  };

  for (k in pub) {
    v = pub[k];
    module.exports[k] = v;
  }

}).call(this);