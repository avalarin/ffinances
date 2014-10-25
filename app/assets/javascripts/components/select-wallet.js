//= require custom-knockout
//= require modules/http

(function() {
  var http = require('http')
  var source = '/wallet.json'
  var wallets = ko.observableArray([])

  function Wallet(data) {
    var wallet = this
    wallet.key = data.key
    wallet.displayName = data.display_name
    wallet.imageUrl = data.image_url
    wallet.currency = {
      code: data.currency.code,
      name: data.currency.name
    }

    wallet.html = ko.computed(function() {
      return '<img src="' + wallet.imageUrl + '" />\n<span>' + wallet.displayName + '</span>'
    })

    wallet.search = function(query) {
      return wallet.displayName.indexOf(query) > -1
    }
  }

  function SelectWalletModel(params, element) {
    var model = this

    var dropdown = AvDropdown.attach($(element).find('.av-dropdown'))

    model.allItems = wallets
    model.search = ko.observable('')
    model.selected = params['selected'] || ko.observable()
    model.loading = ko.observable(false)

    model.selectedHtml = ko.computed(function() {
      return typeof(model.selected()) == 'undefined' ? '' : model.selected().html()
    })

    model.items = ko.computed(function() {
      var search = model.search()
      var items = model.allItems()
      if (search != '') {
        items = _.filter(items, function(item) {
          return item.search(search)
        })
      }
      return items
    })

    model.select = function() {
      model.selected(this)
      dropdown.hide()
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