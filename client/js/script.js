(function($) {
  var geolocation = function (fn) {
    navigator.geolocation.getCurrentPosition(fn, function (error) {
      alert('Error when retrieving location "'+error.message+'".');
    });
  }
  ,getGeos = function () {
    $.ajax({
      type: 'GET'
      ,contentType: "application/json"
      ,url: '/geo'
      ,success: function (data) {
        var str = '';
        $.each(JSON.parse(data).features, function (i, f) {
          str += f.geometry.coordinates[0]+','
            +f.geometry.coordinates[1]+'<br/>'; 
        });
        $('.geos').html(str);
      }
      ,error: function (xhr) {
        alert('Server error: '+xhr.statusText);
      }
    });
  }
  ,putGeo = function (position) {
    $.ajax({
      type: 'PUT'
      ,contentType: "application/json"
      ,dataType: 'json'
      ,url: '/geo'
      ,data: JSON.stringify({
        type: "Feature"
        ,geometry: {
          type: 'Point'
          ,coordinates: [position.coords.longitude, position.coords.latitude]
        }
        ,properties: {
          meta: {
            tag:['lol','rofl']
            ,text: 'Hej hej från webben.'
          }
        }
      })
      ,success: function () {
        alert("Success!");
        getGeos();
      }
      ,error: function (xhr) {
        alert('Server error: '+xhr.statusText);
      }
    });
  }
  ;
  $('.send-position').click(function () {
    geolocation(function (position) {
      putGeo(position);
    });
  });

  $(document).ready(getGeos);
})(jQuery);
