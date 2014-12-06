(function() {
  var http = require('http')

  function UserProfileLinkModel(params, element) {
    var model = this

    model.user = params['user'] || ko.observable()
    model.link = ko.computed(function() {
      return routes.userProfile({ name: model.user.name })
    })
  }

  ko.components.register('user-profile-link', {
    viewModel: {
      createViewModel: function(params, componentInfo) {
        return new UserProfileLinkModel(params, componentInfo.element);
      }
    },
    template: { element: 'user-profile-link-template' }
  })

})()