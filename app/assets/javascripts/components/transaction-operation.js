(function() {
  var http = require('http')

  ko.components.register('transaction-outcome-operation', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          var operation = params['operation'] || new Operation()
          return operation
        }
    },
    template: { element: 'transaction-outcome-operation-template' }
  })

  ko.components.register('transaction-simple-operation', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          var operation = params['operation'] || new Operation()
          return operation
        }
    },
    template: { element: 'transaction-simple-operation-template' }
  })

})()