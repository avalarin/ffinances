(function() {
  var http = require('http')
  var currenciesSource = '/data/currency.json'

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
        value = numeral.replaceInvalidDelimiters(value)
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

    model.allCurrencies = ko.observableArray([])
    model.topCurrencies = ko.observableArray([])
    model.otherCurrencies = ko.observableArray([])
    model.filtredCurrencies = ko.computed(function() {
      var search = model.currenciesSearch().toLowerCase()
      var items = model.allCurrencies()
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.name.toLowerCase().indexOf(search) > -1 || item.code.toLowerCase().indexOf(search) > -1
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
          model.topCurrencies.removeAll()
          model.otherCurrencies.removeAll()

          topCurrencies = { }

          _.each(data.all, function(item) {
            model.allCurrencies.push(item)
            if (data.top.indexOf(item.id) > -1) {
              topCurrencies[item.id] = item
            } else {
              model.otherCurrencies.push(item)
            }
          })

          _.each(data.top, function(id) {
            model.topCurrencies.push(topCurrencies[id])
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