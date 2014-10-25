//= require custom-knockout
//= require modules/http

(function() {

  function SelectValueModel(params, element) {
    var model = this

    var dropdown = AvDropdown.attach($(element).find('.av-dropdown'))

    model.allItems = params['items'] || []
    model.search = ko.observable('')
    model.disabled = params['disabled'] || ko.observable(false)
    model.selected = params['selected'] || ko.observable()
    model.loading = ko.observable(false)
    model.items = ko.computed(function() {
      var search = model.search()
      var items = model.allItems
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.search(search)
        })
      }
      return items
    })

    model.getContent = function(item) {
      return item.content
    }

    model.select = function() {
      model.selected(this)
      dropdown.hide()
    }

    function selectFirst() {
      if (!model.selected() && model.allItems.length > 0) {
        model.selected(model.allItems[0])
      }
    }
    selectFirst()
  }

  ko.components.register('select-value', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new SelectValueModel(params, componentInfo.element);
        }
    },
    template: { element: 'select-value-template' }
  })
})()