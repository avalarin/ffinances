//= require avalarin/dropdown

//= require knockout
//= require chosen-jquery
//= require knockout-chosen
//= require controls/page
//= require modules/http
//= require bootstrap-datepicker
//= require datepicker-locales/ru
//= require controls/page

//= require model/unit
//= require model/product

//= require components/select-wallet
//= require components/select-product
//= require components/money-input
//= require components/unit-input
//= require components/tags-input
//= require components/transaction-operation

var http = require('http')
$(function() {
  var page = new Page()
  var transaction = new TransactionModel()
  page.addControl('transaction', transaction)
  page.attach()
  $('span.transaction-date').datepicker({
    language: 'ru',
  }).on('changeDate', function (e) {
    transaction.date(e.date)
  })
})

function OperationLogicModel(options) {
  options = options || {}
  var model = this
  model.transaction = options['transaction']
  model.wallet = options['wallet'] || ko.observable()
  model.walletCurrency = ko.computed(function() {
    var wallet = model.wallet()
    return typeof(wallet) != 'undefined' ? wallet.currency : {}
  })

  model.product = ko.observable()
  model.count = ko.observable(1)
  model.amount = ko.observable(0)
  model.sum = ko.observable(0)
  model.currency = options['currency'] || ko.observable(model.walletCurrency())
  model.unit = ko.observable()

  model.walletSum = ko.observable(0)  
  
  model.exchangeRate = ko.observable(1)
  model.exchangeRateText = ko.computed(function() {
    var rate = model.exchangeRate()
    var base = model.walletCurrency()
    var target = model.currency()
    if (rate == 0 || typeof(base) == 'undefined' || typeof(target) == 'undefined') return ''
    if (rate < 1) {
      var temp = target
      target = base
      base = temp
      rate = 1 / rate
    }
    return "1 " + base.code + " = " + numeral(rate).format("0,0.00") + " " + target.code
  })
  model.exchangeRateLoading = ko.observable(false)
  model.refreshExchangeRate = function() {
    var base = model.walletCurrency()
    var target = model.currency()
    if (typeof(base) == 'undefined' || typeof(target) == 'undefined') return
    if (typeof(base.code) == 'undefined' || typeof(target.code) == 'undefined') return
    if (base.code == target.code) {
      model.exchangeRate(1)
      return
    }
    model.exchangeRateLoading(true)
    http.request({
      url: '/data/currency/rate',
      data: { base: base.code, target: target.code },
      success: function(data) {
        model.exchangeRate(data.value)
        model.exchangeRateLoading(false)
        syncWalletSum()
      }
    })
  }
  model.exchangeRateLocked = ko.observable(true)
  model.toggleExchangeRateLock = function() {
    model.exchangeRateLocked(!model.exchangeRateLocked())
  }

  model.needExchange = ko.computed(function(argument) {
    var c = model.currency()
    var wc = model.walletCurrency()
    return typeof(c) == 'undefined' || typeof(wc) == 'undefined' || c.code != wc.code
  })

  var lock = (function() {
    var locks = { }
    return function(name, func) {
      if (locks[name]) return
      locks[name] = true
      func()
      locks[name] = false
    }
  })()
  
  function syncWalletSum() {
    if (!model.exchangeRateLocked() && model.walletSum() != 0) {
      syncExchangeRate()
    } else {
      lock('sum', function() {
        model.walletSum(model.sum() / model.exchangeRate())
      })
    }
  }
  function syncSum() {
    if (!model.exchangeRateLocked() && model.sum() != 0) {
      syncExchangeRate()
    } else {
      lock('sum', function() {
        model.sum(model.walletSum() * model.exchangeRate())
      })
    }
    
  }
  function syncExchangeRate() {
    lock('sum', function() {
      model.exchangeRate(model.sum() / model.walletSum())
    })
  }
  model.count.subscribe(function(count) {
    lock('amount', function() {
      model.sum(count * model.amount())
    })
  })
  model.amount.subscribe(function(amount) {
    lock('amount', function() {
      model.sum(model.count() * amount)
    })
  })
  model.sum.subscribe(function(sum) {
    syncWalletSum()
    lock('amount', function() {
      var count = model.count()
      model.amount(count == 0 ? 0 : sum / model.count())
    })
    checkValidation()
  })
  model.walletSum.subscribe(syncSum)
  model.currency.subscribe(function() {
    model.refreshExchangeRate()
  })

  model.wallet.subscribe(function(wallet) {
    model.currency(wallet.currency)
  })
  model.product.subscribe(function(product) {
    if (typeof(product.unit.id) != 'undefined') {
      model.unit(product.unit)
    }
    checkValidation()
  })

  // Валидация
  function checkValidation() {
    if (!model.isValid()) {
      model.valid()
    }
  }
  model.isValid = ko.observable(true)
  model.validationMessage = ko.observable('')
  model.valid = function() {
    if (options.productRequired && (typeof(model.product()) == 'undefined' || !model.product().displayName)) {
      model.isValid(false)
      model.validationMessage(localization.productRequired)
      return false
    }
    if (model.sum() <= 0) {
      model.isValid(false)
      if (options.positiveSumRequired) {
        model.validationMessage(localization.sumGreaterThan)
      } else {
        model.validationMessage(localization.sumGreaterOrLessThan)
      }
      return false
    }
    if (model.exchangeRate() <= 0) {
      model.isValid(false)
      model.validationMessage(localization.rateGreaterThan)
      return false
    }
    if (typeof(model.wallet()) == 'undefined' || !model.wallet().displayName) {
      model.isValid(false)
      model.validationMessage(localization.walletRequired)
      return false
    }
    model.isValid(true)
    model.validationMessage('')
    return true
  }

  model.getData = function() {
    var unit = model.unit()
    var product = model.product()
    return {
      wallet: model.wallet().key,
      currency: model.currency().code,
      currency_rate: model.exchangeRate(),
      product: typeof(product) == "undefined" ? null : {
          id: product.unit.id,
          name: product.unit.displayName
      },
      count: model.count(),
      unit: typeof(unit) == "undefined" ? null : model.unit().id,
      amount: model.amount(),
      sum: model.sum()
    }
  }

}

function TransactionModel() {
  var model = this

  model.date = ko.observable(new Date())
  model.dateText = ko.computed(function() {
    return moment(model.date()).format('LL')
  })

  model.mode = ko.observable($('input[name=mode]').val())
  model.setMode = function(s, event) {
    model.mode($(event.currentTarget).attr('data-value'))
  }
  model.modeText = ko.computed(function() {
    return $('.transaction-mode a[data-value=' + model.mode() + ']').text()
  })

  model.tags = ko.observableArray([])
  model.description = ko.observable('')
  model.fromOperation = new Operation({ positiveSumRequired: true })
  model.toOperation = new Operation({ positiveSumRequired: true })

  model.operations = ko.observableArray([])
  model.createOperation = function() {
    return new Operation({ 
      transaction: model,
      wallet: model.fromOperation.wallet, 
      currency: model.fromOperation.currency,
      productRequired: true,
      positiveSumRequired: true
    })
  }
  model.addOperation = function() {
    var op = model.createOperation()
    model.operations.push(op)
  }
  model.addOperationAndFocus = function() {
    model.addOperation()
    setTimeout(function() { 
      $('.detalization .transaction-operation').eq(-1).find('input').eq(0).focus()
    }, 20)
  }

  model.deleteOperation = function(op) {
    if (model.operations().length == 1) {
      var temp = model.operations()
      temp[0] = model.createOperation()
      model.operations.valueHasMutated();
    } else {
      model.operations.remove(op)
    }
  }
  model.addOperation()

  model.valid = function() {
    var valid = true
    if (model.mode() == 'outcome') {
      updateSum()
    }
    valid = model.fromOperation.valid() && valid
    if (model.mode() == 'transfer') {
      valid = model.toOperation.valid() && valid
    }
    if (model.mode() == 'outcome') {
      _.each(model.operations(), function(op) {
        valid = op.valid() && valid
      })
    }
    return valid
  }

  model.save = function() {
    if (!model.valid()) return
    var data = { 
      tags: _.map(model.tags(), function(tag) {
        return tag.id
      }),
      date: model.date(),
      description: model.description(),
      type: model.mode()
    }
    if (model.mode() == 'income') {
      data.operations = [
        model.fromOperation.getData()
      ]
    } else if (model.mode() == 'transfer') {
      var fromData = model.fromOperation.getData()
      var toData = model.toOperation.getData()
      fromData.sum = fromData.sum * -1
      fromData.amount = fromData.amount * -1
      data.operations = [        
        fromData, toData
      ]
    } else if (model.mode() == 'outcome') {
      data.operations = _.map(model.operations(), function(op) {
        var data = op.getData()
        data.sum = data.sum * -1
        data.amount = data.amount * -1
        return data
      })
    } else {
      throw 'Invalid mode.'
    }
    
    http.request({
      url: '/transaction/new',
      type: 'POST',
      contentType: "application/json; charset=utf-8",
      dataType: 'json',
      data: JSON.stringify({ transaction: data }),
      success: function(data) {
        console.log(data)
      }
    })
  }

  function updateSum() {
      model.fromOperation.sum(_.reduce(model.operations(), function(sum, op) {
        return sum + op.sum()
      }, 0))
    }

  var f = (function() {
    var subscriptions = { }

    model.operations.subscribe(function(operations) {
      _.each(operations, function(operation) {
        if (!operation.sumSubscribed) {
          operation.sum.subscribe(updateSum)
          operation.sumSubscribed = true
        }
      })
    })
  })()
}