//= require knockout
//= require modules/http
//= require avalarin/dropdown
//= require model/user

(function() {
  var http = require('http')
  var source = '/data/user.json'

  function SelectUserModel(params, element) {
    var model = this

    var dropdown = AvDropdown.attach($(element).find('.av-dropdown'))

    model.multiple = false

    model.search = ko.observable('')
    model.loading = ko.observable(false)
    model.disabled = params['disabled'] || ko.observable(false)
    model.selected = params['selected'] || ko.observableArray([])
    model.selectedOne = ko.computed(function() {
      var selected = model.selected()
      if (selected.length == 0) {
        return undefined
      } else {
        return selected[0]
      }
    })

    model.items = ko.observableArray([])

    model.select = function() {
      if (!model.multiple) {
        model.selected.removeAll()
      }
      model.selected.push(this)
      dropdown.hide()
      model.search('')
    }

    model.refresh = function() {
      var search = model.search()
      if (!search) {
        model.items.removeAll()
        return
      }
      model.loading(true)
      http.request({
        url: source,
        data: { search: search },
        success: function(data) {
          model.items.removeAll()
          _.each(data, function(item) {
            model.items.push(new User(item))
          })
          model.loading(false)
        }
      })
    }
    model.search.subscribe(function() {
      model.refresh()
    })
  }

  ko.components.register('select-user', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new SelectUserModel(params, componentInfo.element);
        }
    },
    template: { element: 'select-user-template' }
  })
})()