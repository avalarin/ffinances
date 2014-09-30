//= require knockout
//= require modules/http

(function() {
  var http = require('http')
  var unitsSource = '/data/unit.json'
  var units = ko.observableArray([])

  function UnitInputModel(params, element) {
    var model = this
    var staticUnit = typeof(params['staticUnit'] != 'undefined') ? params['staticUnit'] : false

    var $element = $(element)
    var input = $element.find('.value')
    if (!staticUnit) {
      var dropdown = AvDropdown.attach($element.find('.av-dropdown'), {
        onshow: function() {
          model.dropdownShown(true)
        },
        onhide: function() {
          model.dropdownShown(false)
        }
      })
    }

    model.unit = params['unit'] || ko.observable()
    model.unitShortName = ko.computed(function() {
      var unit = model.unit()
      return unit ? unit.shortName : ''
    })

    model.format = ko.computed(function() {
      var unit = model.unit()
      if (typeof(unit) == 'undefined') {
        return '0,0'
      } else {
        if (unit.decimals == 0) return '0,0'
        return '0,0.' + Array(unit.decimals).join("0") 
      }
    })
    model.dropdownShown = ko.observable(false)

    model.staticUnit = ko.observable(staticUnit)
    model.value =  params['value'] || ko.observable(0)
    model.valueString = ko.pureComputed({
      read: function() {
        var format = model.format()
        return numeral(model.value()).format(format)
      },
      write: function(value) {
        model.value(numeral().unformat(value) || 0)
      }
    })

    model.unitsSearch = ko.observable('')
    model.loadingUnits = ko.observable(false)
    model.allUnits = units
    model.units = ko.computed(function() {
      var search = model.unitsSearch()
      var items = model.allUnits()
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.name.indexOf(search) > -1 || item.code.indexOf(search) > -1
        })
      }
      return items
    })
    model.setUnit = function(unit) {
      model.unit(unit)
      if (!staticUnit) dropdown.hide()
    }
    
    function selectFirst() {
      if (!model.unit() && model.allUnits().length > 0) {
        model.unit(model.allUnits()[0])
      }
    }

    model.refreshUnits = function() {
      model.loadingUnits(true)
      http.request({
        url: unitsSource,
        success: function(data) {
          model.allUnits.removeAll()
          _.each(data, function(item) {
            model.allUnits.push(new UnitModel(item))
          })
          selectFirst()
          model.loadingUnits(false)
        }
      })
    }
    model.valueString.subscribe(function(value) {
      autoResize(input, value)
    })

    selectAllOnFocus(input)
    autoResize(input, model.valueString())


    if (model.allUnits().length == 0) {
      model.refreshUnits()
    } else {
      selectFirst()
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

  ko.components.register('unit-input', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new UnitInputModel(params, componentInfo.element)
        }
    },
    template: { element: 'unit-input-template' }
  })
})()