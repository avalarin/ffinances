window.routes = new (function() {
  var routes = this

  routes.editTransaction = function(id) {
    return '/transaction/' + id + '/edit'
  }

  routes.updateTransaction = function() {
    return '/transaction/update'
  }

})