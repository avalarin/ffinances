//= require avalarin/dropdown
//= require model/book

(function() {
  var http = require('http')

  function Model(params, element) {
    var model = this;
    // TODO Костыль, жесткая привязка к <!-- ko: ... -->
    // В element будет содержаться коментарий, чтобы получить dropdown нужно вывать метод next()
    // который вернет следующий элемент
    element = $(element).next()

    var dropdown = AvDropdown.attach(element, {
      onshow: function () {
        if (model.items().length == 0) {
          model.refresh();
        }
      }
    })

    model.items = ko.observableArray([])
    model.loading = ko.observable(false)

    model.choose = function(book, event) {
      if (book.key != window.session.book.key) {
        http.request({
          url: routes.bookChoose(),
          data: { key: book.key },
          type: 'POST',
          success: function() {
            location.reload()
          }
        })
      }
    }
    model.goSettings = function(book, event) {
      var settingsUrl = routes.book(book.key)
      http.redirect({ url: settingsUrl })
      event.stopPropagation()
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        url: routes.books(),
        success: function(items) {
          model.items.removeAll()
          _.each(items, function(item) {
            model.items.push(new Book(item))
          })
        },
        complete: function() {
          model.loading(false)
        }
      })
    }
  }
  ko.components.register('current-book-menu', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new Model(params, componentInfo.element)
        }
    },
    template: { element: 'current-book-menu-template' }
  })

})()