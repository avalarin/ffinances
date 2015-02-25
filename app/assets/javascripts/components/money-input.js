(function() {
  var http = require('http')
  var currenciesSource = '/data/currency.json'
  var currencies = ko.observableArray([])

  var invalidDelimitersRegexp = getInvalidDelimitersRegExp([ '.', ',' ])

  function MoneyInputModel(params, element) {
    var model = this
    var format = params['format'] || '0,0.00'
    var staticCurrency = typeof(params['staticCurrency'] != 'undefined') ? params['staticCurrency'] : false

    var $element = $(element)
    var input = $element.find('.value')
    if (!staticCurrency) {
      var dropdown = $(element).find('.av-dropdown').avDropdown()
      dropdown.on('shown.av.dropdown', function() { model.dropdownShown(true) })
              .on('hidden.av.dropdown', function() { model.dropdownShown(false) })
    }

    model.dropdownShown = ko.observable(false)

    model.staticCurrency = ko.observable(staticCurrency)
    model.value =  params['value'] || ko.observable(0)
    model.valueString = ko.pureComputed({
      read: function() {
        return numeral(model.value()).format(format)
      },
      write: function(value) {
        value = value.replace(invalidDelimitersRegexp, numeral.languageData().delimiters.decimal)
        model.value(numeral().unformat(value) || 0)
      }
    })

    model.currency = params['currency'] || ko.observable()
    model.currencyCode = ko.computed(function() {
      var currency = model.currency()
      return typeof(currency) == "undefined" ? '' : currency.code
    })

    model.currenciesSearch = ko.observable('')
    model.loadingCurrencies = ko.observable(false)
    model.allCurrencies = currencies
    model.currencies = ko.computed(function() {
      var search = model.currenciesSearch()
      var items = model.allCurrencies()
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.name.indexOf(search) > -1 || item.code.indexOf(search) > -1
        })
      }
      return items
    })
    model.setCurrency = function(currency) {
      model.currency({code: currency.code, name: currency.name})
      if (!staticCurrency) dropdown.avDropdown('hide')
    }

    model.refreshCurrencies = function() {
      model.loadingCurrencies(true)
      http.request({
        url: currenciesSource,
        success: function(data) {
          model.allCurrencies.removeAll()
          _.each(data, function(item) {
            model.allCurrencies.push(item)
          })
          model.loadingCurrencies(false)
        }
      })
    }

    model.valueString.subscribe(function(value) {
      autoResize(input, value)
    })

    selectAllOnFocus(input)
    autoResize(input, model.valueString())


    if (model.allCurrencies().length == 0) {
      model.refreshCurrencies()
    }

  }

  function getInvalidDelimitersRegExp(delimiters) {
    var decimalDelimiter = numeral.languageData().delimiters.decimal
    var thousandsDelimiter = numeral.languageData().delimiters.thousands
    var regexParts = []

    for (var i = 0; i < delimiters.length; i++) {
      var d = delimiters[i]
      if (d != decimalDelimiter && d != thousandsDelimiter) {
        regexParts.push(d)
      }
    }

    return new RegExp('[' + regexParts.join('|') + ']');
  }

  function selectAllOnFocus(element) {
    element.on('focus', function(e) {
      $(this).one('mouseup', function () {
          $(this).select()
          return false
        }).select()
    })
  }

  function autoResize(element, text) {
    var sample = $('<span></span>').hide().insertAfter(element);
    var resizeManual = function(text) {
      sample.text(text)
      element.width(Math.max(25, sample.width() + 5))
    }
    var resize = function() {
      resizeManual(element.val())
    }
    element.on('keypress keyup keydown focusout change', resize)
    resizeManual(text)
    return resizeManual
  }

  ko.components.register('money-input', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new MoneyInputModel(params, componentInfo.element)
        }
    },
    template: { element: 'money-input-template' }
  })
})()