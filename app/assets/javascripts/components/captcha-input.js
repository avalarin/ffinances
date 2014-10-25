//= require custom-knockout
//= require modules/http

(function () {
  "use strict"
  var http = require('http')

  function CaptchaModel(params) {
    params = params || {}
    var model = this

    function generateNew(callback) {
      http.request({
        url: '/captcha/new',
        type: 'POST',
        success: function(resp) {
          callback(resp.code)
        }
      })
    }

    model.code = params.code || ko.observable('')
    model.value = params.value || ko.observable('')
    model.loading = ko.observable(false)
    model.imageUrl = ko.computed(function() {
      return '/captcha?code=' + model.code()
    })

    model.update = function() {
      model.loading(true)
      generateNew(function(code) {
        model.code(code)
        model.value('')
        model.loading(false)
      })
    }

    model.update()

  }
  window.CaptchaModel = CaptchaModel

  ko.components.register('captcha-input', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          if('model' in params) {
            return params.model
          }
          return new CaptchaModel(params, componentInfo.element)
        }
    },
    template: { element: 'captcha-input-template' }
  })

})()