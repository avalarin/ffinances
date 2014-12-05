window.routes = new (function() {
  var routes = this

  function format(url, params) {
    params = params || {}
    url = url.replace(/\:(\w+)/g,
        function (a, b) {
          var r = params[b];
          return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
    )
    if (params.format) {
      url += '.' + params.format
    }
    return url
  }

  function route(name, template) {
    routes[name] = function(params) {
      return format(template, params)
    }
  }

  route('books', '/book/index')
  route('book', '/book/:key')
  route('bookChoose', '/book/choose')
  route('bookUsers', '/book/users')
  route('bookUser', '/book/users/:name')
  route('editTransaction', '/transaction/:id/edit')
  route('updateTransaction', '/transaction/update')
})