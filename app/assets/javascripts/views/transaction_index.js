//= require components/user-profile-link
//= require controls/modal
//= require model/wallet
//= require model/product
//= require model/unit
//= require model/currency
//= require model/transaction
//= require model/pagination

//= require bootstrap-datepicker
//= require datepicker-locales/ru

function stripTime(date, h, m, s) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), h || 0, m || 0, s || 0);
}

function makeFromDate(date) {
  return stripTime(date)
}

function makeToDate(date) {
  return stripTime(date, 23, 59, 59)
}

(function() {

  function TransationsModel(options) {
    options = options || {}
    var http = require('http')
    var model = this;
    var detailsModal = options.detailsModal
    var deleteModal = options.deleteModal

    model.pagination = new Pagination()
    model.pagination.page.subscribe(function() { model.refresh() })

    model.dates = {
      dateFrom: ko.observable(makeFromDate(new Date())),
      dateTo: ko.observable(makeToDate(new Date())),
      select: function(period) {
        var from = moment(new Date())
        var to = moment(new Date())
        if (period == 'last_week') {
          from.subtract(7, 'days')
        } else if (period == 'last_month') {
          from.subtract(30, 'days')
        } else if (period == 'current_week') {
          from.weekday(0)
          to.weekday(6)
        } else if (period == 'current_month') {
          from.date(1)
          to.add(1, 'months').date(1).subtract(1, 'days')
        } else if (period == 'current_year') {
          from.dayOfYear(1)
          to.add(1, 'years').dayOfYear(1).subtract(1, 'days')
        }
        model.dates.dateFrom(makeFromDate(from.toDate()))
        model.dates.dateTo(makeToDate(to.toDate()))
      }
    }
    model.dates.dateFromText = ko.computed(function() {
      return moment(model.dates.dateFrom()).format('ll')
    })
    model.dates.dateToText = ko.computed(function() {
      return moment(model.dates.dateTo()).format('ll')
    })
    model.dates.dateFrom.subscribe(function(value) {
      if (value > model.dates.dateTo()) model.dates.dateTo(makeToDate(value))
      model.refresh()
    })
    model.dates.dateTo.subscribe(function(value) {
      if (value < model.dates.dateFrom()) model.dates.dateFrom(makeFromDate(value))
      model.refresh()
    })

    model.loading = ko.observable(false)
    model.items = ko.observableArray([])
    model.goDetails = function() {
      var transaction = this
      detailsModal.show(transaction)
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        beforeSend: function(xhr) {
          if (model.currentRequest) {
            model.currentRequest.abort()
          }
          model.currentRequest = xhr
        },
        url: '/transaction.json',
        data: {
          page: model.pagination.page(),
          from: model.dates.dateFrom(),
          to: model.dates.dateTo()
        },
        success: function(data) {
          model.currentRequest = undefined
          model.items.removeAll()

          model.pagination.update(data.pagination)

          _.each(data.items, function(item) {
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

  var transactionDetails = new TransactionModal($('#transaction-details-modal'))
  var transactionDelete = new TransactionDeleteModal($('#transaction-delete-modal'))
  window.page.addControl('transactionDetailsModal', transactionDetails)
  window.page.addControl('transactionDeleteModal', transactionDelete)
  window.page.addControl('transactions', new TransationsModel({
    detailsModal: transactionDetails,
    deleteModal: transactionDelete
  }))

  window.page.controls.transactions.refresh()

  $('span.date-from').datepicker({
    language: 'ru',
  }).on('changeDate', function (e) {
    window.page.controls.transactions.dates.dateFrom(makeFromDate(e.date))
  })

  $('span.date-to').datepicker({
    language: 'ru',
  }).on('changeDate', function (e) {
    window.page.controls.transactions.dates.dateTo(makeToDate(e.date))
  })
})()