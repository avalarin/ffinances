//= require components/captcha-input

(function() {
  var http = require('http')
  var fieldNames = {
    'name': 'user[name]',
    'captcha': 'captcha[value]'
  }
  var model = new (function() {
    var m = this
    this.name = ko.observable('')
    this.captcha = new CaptchaModel()
  })

  window.page.addControl('restore', model)
})()