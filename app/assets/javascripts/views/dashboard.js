//= require knockout
//= require controls/page
//= require modules/http

$(function() {
  var page = new Page()
  page.addControl('wallets', new WalletsModel())
  page.addControl('transactions', new TransationsModel())
  page.attach()

  page.controls.wallets.refresh()
  page.controls.transactions.refresh()
})

function WalletsModel() {
  var http = require('http')
  var model = this;

  function Wallet(data) {
    this.display_name = data.display_name 
    this.image_url = data.image_url
  }

  model.loading = ko.observable(false)
  model.items = ko.observableArray([])

  model.refresh = function() {
    model.loading(true)
    http.request({
      url: '/wallet.json',
      success: function(data) {
        model.items.removeAll()
        _.each(data, function(item) {
          model.items.push(new Wallet(item))
        })
        model.loading(false)
      }
    })
  }
}

function TransationsModel() {
  var http = require('http')
  var model = this;

  function Transaction(data) {
    this.date = data.date
    this.dateText = moment(this.date).format('L')
    this.description = data.description
    this.creator = {
      name: data.creator.name,
      email: data.creator.name,
      displayName: data.creator.display_name,
      avatarUrl: data.creator.avatar_url
    }
    this.tags = _.map(data.tags, function(tag) {
      return {
        id: tag.id,
        text: tag.text
      }
    }) 
    this.operations = _.flatten(_.map(data.operations_groupped, function(group) {
      return _.map(group.sums, function(sum) {
        return {
          wallet: {
            key: group.wallet.key,
            displayName: group.wallet.display_name,
            imageUrl: group.wallet.image_url
          }, 
          sum: sum.sum,
          sumText: numeral(sum.sum).format('+0,0.00'),
          type: sum.sum < 0 ? 'out' : 'in',
          currency: { // TODO Переместить модель для currency в отдельный файл
            id: sum.currency.id,
            code: sum.currency.code,
            symbol: sum.currency.symbol,
            name: sum.currency.name,
            globalName: sum.currency.global_name
          }
        }
      })
    }))
  }

  model.loading = ko.observable(false)
  model.items = ko.observableArray([])

  model.refresh = function() {
    model.loading(true)
    http.request({
      url: '/transaction.json',
      success: function(data) {
        model.items.removeAll()
        _.each(data, function(item) {
          model.items.push(new Transaction(item))
        })
        model.loading(false)
      }
    })
  }
}
