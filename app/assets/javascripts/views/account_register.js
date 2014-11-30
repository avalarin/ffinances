//= require components/captcha-input

(function() {
  var http = require('http')
  var fieldNames = {
    'display_name': 'user[display_name]',
    'name': 'user[name]',
    'email': 'user[email]',
    'password': 'user[password]',
    'captcha': 'captcha[value]'
  }
  var model = new (function() {
    var m = this
    this.displayName = ko.observable('')
    this.name = ko.observable('')
    this.email = ko.observable('')
    this.password = ko.observable('')
    this.captcha = new CaptchaModel()

    this.register = function() {
      var form = $('#register-form')
      if (!form.valid()) return
      $('#register-form .btn-success').addClass('loading disabled')
      http.request({
        url: '/register',
        type: 'POST',
        data: form.serialize(),
        success: function(data) {
          http.redirect({
            url: '/register/success'
          })
        },
        error: function(status, message, data) {
          if (message == 'validation_error') {
            var errors = {}
            _.each(data, function(value, key) {
              if (key in fieldNames) {
                errors[fieldNames[key]] = value[0]
              }
            })
            $('#register-form').validate().showErrors(errors)
            m.captcha.update()
            $('#captcha-value').val('')
            $('#register-form .btn-success').removeClass('disabled loading')
          }
        }
      })

      }
  })

  window.page.addControl('register', model)
})()