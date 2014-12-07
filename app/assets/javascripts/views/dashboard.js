//= require components/user-profile-link
//= require controls/modal
//= require model/wallet
//= require model/product
//= require model/unit
//= require model/currency

(function() {

  function WalletsModel() {
    var http = require('http')
    var model = this;

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
      avatarUrl: data.creator.avatar_url
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

  function TransationsModel(options) {
    options = options || {}
    var http = require('http')
    var model = this;
    var detailsModal = options.detailsModal
    var deleteModal = options.deleteModal

    model.loading = ko.observable(false)
    model.items = ko.observableArray([])
    model.goDetails = function() {
      var transaction = this
      detailsModal.show(transaction)
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        url: '/transaction.json?limit=15',
        success: function(data) {
          model.items.removeAll()
          _.each(data, function(item) {
            var transaction = new Transaction(item, { deleteModal: deleteModal })
            transaction.delete = function() {
              model.items.remove(transaction)
            }
            model.items.push(transaction)
          })
          model.loading(false)
        }
      })
    }
  }

  function TransactionModal(element) {
    var base = new Modal(element)
    var modal = _.extend(this, base)
    modal.transaction = ko.observable()

    modal.show = function (transaction) {
      modal.transaction(transaction)

      if (!transaction.detalization.loaded) {
        transaction.detalization.load()
      }

      base.show()
    }

  }

  function TransactionDeleteModal(element) {
    var base = new TransactionModal(element)
    var modal = _.extend(this, base)
    var http = require('http')

    modal.deleting = ko.observable(false)
    modal.doDelete = function() {
      modal.deleting(true)
      http.request({
        url: '/transaction/' + modal.transaction().id,
        type: 'DELETE',
        success: function() {
          modal.transaction().delete()
          modal.close()
        },
        complete: function() {
          modal.deleting(false)
        }
      })
    }

  }

  window.page.addControl('wallets', new WalletsModel())
  var transactionDetails = new TransactionModal($('#transaction-details-modal'))
  var transactionDelete = new TransactionDeleteModal($('#transaction-delete-modal'))
  window.page.addControl('transactionDetailsModal', transactionDetails)
  window.page.addControl('transactionDeleteModal', transactionDelete)
  window.page.addControl('transactions', new TransationsModel({
    detailsModal: transactionDetails,
    deleteModal: transactionDelete
  }))

  window.page.controls.wallets.refresh()
  window.page.controls.transactions.refresh()
})()