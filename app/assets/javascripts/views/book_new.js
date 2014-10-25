//= require custom-knockout
//= require chosen-jquery
//= require knockout-chosen
//= require controls/page
//= require modules/http

var http = require('http')

$(function() {
  var page = new Page()
  page.addControl('currencies', new CurrenciesModel())
  page.attach()
})

function Currency(data) {
  this.code = data.code
  this.name = data.name
  this.symbol = data.symbol
  this.auto = data.auto
}

function CurrenciesModel() {
  var model = this;

  model.selectedCountry = ko.observable()
  model.selectedCurrency = ko.observable()
  model.list = ko.observableArray([])
  model.list_auto = ko.computed(function() {
    return _.filter(model.list(), function(item) { return item.auto })
  })
  model.list_manual = ko.computed(function() {
    return _.filter(model.list(), function(item) { return !item.auto })
  })

  model.add = function(currency, replace) {
    if (typeof(currency) == 'undefined') return
    var exist_currency = _.find(model.list(), function(cur) { return cur.code == currency.code } )
    if (typeof(exist_currency) != 'undefined') {
      if (replace) {
        model.delete(exist_currency)
      } else {
        return
      }
    }
    model.list.push(currency)
  }

  model.delete = function(currency) {
    model.list.remove(currency)
  }

  model.addSelected = function() {
    parts = model.selectedCurrency().split(';')
    code = parts[0]
    name = parts[1]
    symbol = parts[2]
    model.add(new Currency({ code: code, name: name, symbol: symbol }))
  }

  model.selectedCountry.subscribe(function(value) {
    if (typeof(value) == 'undefined' || value == '') return
    http.request({
      url: '/data/country/' + value + '/currencies',
      success: function(resp) {
        filtered = _.filter(model.list(), function(currency) {
          return !currency.auto
        })
        model.list.removeAll()
        _.each(filtered, function(currency) {
          model.add(new Currency(currency))
        })

        _.each(resp.currencies, function(currency) {
          currency.auto = true
          model.add(new Currency(currency), true)
        })
      }
    })
  })

}