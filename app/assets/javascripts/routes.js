window.routes = new (function() {
  var routes = this

  routes.books = function() {
    return '/book.json'
  }

  routes.book = function(key) {
    return '/book/' + key
  }

  routes.bookChoose = function() {
    return '/book/choose'
  }

  routes.editTransaction = function(id) {
    return '/transaction/' + id + '/edit'
  }

  routes.updateTransaction = function() {
    return '/transaction/update'
  }

})