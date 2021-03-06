(function() {
  var http = require('http')
  var source = '/product.json'

  function SelectProductModel(params, element) {
    var model = this
    var dropdown = $(element).find('.av-dropdown').avDropdown()
    dropdown.on('hidden.av.dropdown', function() {
      if (model.search() != model.selectedText()) {
        var product = new Product()
        product.displayName = model.search()
        model.selected(product)
      }
    })

    model.items = ko.observableArray([])
    model.selected = params['selected'] || ko.observable()
    model.loading = ko.observable(false)

    model.selectedText = ko.computed(function() {
      var selected = model.selected()
      return typeof(selected) == 'undefined' ? '' : selected.displayName
    })
    model.search = ko.observable(model.selectedText())

    model.select = function() {
      model.selected(this)
      model.search(this.displayName)
      dropdown.avDropdown('hide')
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        url: source,
        data: { search: model.search },
        success: function(data) {
          model.items.removeAll()
          _.each(data, function(item) {
            model.items.push(new Product(item))
          })
          model.loading(false)
        }
      })
    }

    model.search.subscribe(function(v) {
      if (v != '') {
        dropdown.avDropdown('show')
        model.refresh()
      } else {
        dropdown.avDropdown('hide')
      }
    })

  }

  ko.components.register('select-product', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new SelectProductModel(params, componentInfo.element);
        }
    },
    template: { element: 'select-product-template' }
  })
})()