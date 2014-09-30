//= require modules/http

var http = require('http')

function choose(key) {
  http.request({
    url: '/book/choose',
    data: { key: key },
    type: 'POST',
    success: function() {
      location.reload()
    }
  })
  
}