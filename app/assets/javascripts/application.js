//= require jquery
//= require jquery.validate
//= require jquery.validate.unobtrusive
//= require jquery_ujs
//= require bootstrap
//= require underscore
//= require modules/require

//= require numeral
//= require numeral-locales/ru.js

//= require moment
//= require moment-locales/ru.js

define('jquery', function () {
  return jQuery;
})

numeral.language('ru')
moment.locale('ru')

if (!window.values) window.values = {}
if (!window.urls) window.urls = {}
if (!window.localization) window.localization = {}