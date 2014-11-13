//= require model/wallet

(function() {
  var http = require('http')
  var source = '/wallet.json'
  var wallets = ko.observableArray([])

  function SelectWalletModel(params, element) {
    var model = this

    var dropdown = $(element).find('.av-dropdown').avDropdown()

    model.allItems = wallets
    model.search = ko.observable('')
    model.selected = params['selected'] || ko.observable()
    model.loading = ko.observable(false)

    model.items = ko.computed(function() {
      var search = model.search()
      var items = model.allItems()
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.displayName.indexOf(search) > -1
        })
      }
      return items
    })

    model.select = function() {
      model.selected(this)
      dropdown.avDropdown('hide')
    }

    function selectFirst() {
      if (!model.selected() && model.allItems().length > 0) {
        model.selected(model.allItems()[0])
      }
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        url: source,
        success: function(data) {
          model.allItems.removeAll()
          _.each(data, function(item) {
            model.allItems.push(new Wallet(item))
          })
          selectFirst()
          model.loading(false)
        }
      })
    }

    if (model.allItems().length == 0) {
      model.refresh()
    } else {
      selectFirst()
    }
  }

  ko.components.register('select-wallet', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new SelectWalletModel(params, componentInfo.element);
        }
    },
    template: { element: 'select-wallet-template' }
  })
})()