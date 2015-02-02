function Transaction(data, options) {
  options = options || {}
  var http = require('http')
  var transaction = this
  var deleteModal = options.deleteModal

  this.id = data.id
  this.date = data.date
  this.dateText = moment(this.date).format('L')
  this.description = data.description
  this.creator = {
    name: data.creator.name,
    email: data.creator.name,
    displayName: data.creator.display_name,
    smallAvatarUrl: data.creator.small_avatar_url
  }

  var isAdmin = session.permissions.bookAdmin
  var isMaster = session.permissions.bookMaster
  this.canManage = isAdmin || (isMaster && transaction.creator.name == session.user.name)

  this.tags = _.map(data.tags, function(tag) {
    return {
      id: tag.id,
      text: tag.text
    }
  })
  this.operations = _.flatten(_.map(data.operations_groupped, function(group) {
    return _.map(group.sums, function(sum) {
      return {
        wallet: new Wallet(group.wallet),
        sum: sum.sum,
        sumText: numeral(sum.sum).format('+0,0.00'),
        type: sum.sum < 0 ? 'out' : 'in',
        currency: new Currency(sum.currency)
      }
    })
  }))

  this.edit = function() {
    http.redirect({ url: routes.editTransaction({ id: transaction.id }) })
  }

  this.remove = function() {
    deleteModal.show(transaction)
  }

  this.detalization = new (function () {
    var detalization = this
    detalization.loading = ko.observable(false)
    detalization.loaded = false
    detalization.items = ko.observableArray([])
    detalization.load = function() {
      detalization.loading(true)
      http.request({
        url: '/transaction/' + transaction.id,
        success: function(data) {
          detalization.items.removeAll()
          _.each(data.operations, function(item) {
            detalization.items.push({
              rate: item.currency_rate,
              rateText: numeral(item.currency_rate).format('0,0.00'),
              count: item.count,
              countText: numeral(item.count).format('0,0.00'),
              amount: item.amount,
              amountText: numeral(item.amount).format('0,0.00'),
              sum: item.sum,
              sumText: numeral(item.sum).format('0,0.00'),
              wallet: new Wallet(item.wallet),
              currency: new Currency(item.currency),
              product: item.product ? new Product(item.product) : null,
              unit: item.unit ? new Unit(item.unit) : null
            })
          })
          detalization.loaded = true
        },
        complete: function() {
          detalization.loading(false)
        }
      })
    }
  })
}