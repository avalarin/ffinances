//= require custom-knockout
//= require modules/http
//= require model/user
//= require components/select-user
//= require components/select-value

(function() {
  var http = require('http')

  function BookModel() {
    var model = this

    model.users = ko.observableArray([])
    model.usersLoading = ko.observable(false)
    model.refreshUsers = function() {
      model.usersLoading(true)
      http.request({
        url: '/book/' + book.key + '/users',
        success: function(data) {
          model.users.removeAll()
          _.each(data, function(user) {
            var userModel = new User(user)
            userModel.bookRole = ko.observable(user.book_role)
            model.users.push(userModel)
          })
          model.usersLoading(false)
        } 
      })
    }

    model.setRole = function(user, role, event) {
      var button = $(event.target).closest('.btn-group').find('.btn').addClass('loading disabled')

      http.request({
        url: '/book/' + book.key + '/users/' + user.name,
        type: 'POST',
        data: { role: role.key },
        success: function() {
          if (role.key == 'delete') {
            model.users.remove(user)
          } else {
            user.bookRole(role.key)
          }
          model.refreshUsers()
        },
        complete: function() {
          button.removeClass('loading disabled')
        }
      })

    }

    model.addUser = new (function() {
      var addUserModel = this

      addUserModel.visible = ko.observable(false)
      addUserModel.loading = ko.observable(false)

      addUserModel.users = ko.observableArray()
      addUserModel.role = ko.observable('')
      addUserModel.canAdd = ko.computed(function() {
        return addUserModel.users().length > 0 && addUserModel.role() && !addUserModel.loading()
      })


      addUserModel.add = function(eve, eve2) {
        if (!addUserModel.canAdd()) return
        addUserModel.loading(true)
        var user = addUserModel.users()[0]
        addUserModel.users.removeAll()

        http.request({
          url: '/book/' + book.key + '/users',
          type: 'POST',
          data: { user: user.name, role: addUserModel.role().key },
          success: function() {
            model.refreshUsers()
          },
          complete: function() {
            addUserModel.loading(false)
          }
        })

      }
    })

    model.refreshUsers()
  }

  ko.applyBindings(new BookModel())

})()