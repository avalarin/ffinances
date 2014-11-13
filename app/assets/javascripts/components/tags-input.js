(function() {
  var http = require('http')
  var source = '/tag.json'
  var createUrl = '/tag/new'

  function Tag(data) {
    this.id = data.id
    this.text = data.text
  }

  function TagsInputModel(params, element) {
    var model = this
    var $element = $(element)
    var searchInput = $element.find('input.search')
    var dropdown = $(element).find('.av-dropdown').avDropdown()
    var dropdownShowed = false;

    model.search = ko.observable('')
    model.loading = ko.observable(false)
    model.selected = params['selected'] || ko.observableArray([])
    model.allItems = ko.observableArray([])

    model.search.subscribe(function(newValue) {
      if (newValue == '' && dropdownShowed) {
        dropdown.avDropdown('hide')
        dropdownShowed = false
      } else if (!dropdownShowed) {
        dropdown.avDropdown('show')
        dropdownShowed = true
      }
    })

    model.items = ko.computed(function() {
      var search = model.search()
      if (search == '') return []
      return _.filter(model.allItems(), function(item) {
        return item.text.indexOf(search) > -1;
      })
    })

    model.create = function() {

      http.request({
        url: createUrl,
        type: 'POST',
        data: { text: model.search() },
        success: function(data) {
          var nTag = new Tag(data)
          model.allItems.push(nTag)
          model.add(nTag)
        }
      })
    }

    model.add = function(tag, event) {
      model.selected.push(tag)
      model.search('')
      searchInput.focus()
    }

    model.remove = function(tag) {
      model.selected.remove(tag)
    }

    model.refresh = function() {
      model.loading(true)
      http.request({
        url: source,
        success: function(data) {
          model.allItems.removeAll()
          _.each(data, function(item) {
            model.allItems.push(new Tag(item))
          })
          model.loading(false)
        }
      })
    }

    model.refresh()

  }


  ko.components.register('tags-input', {
    viewModel: {
        createViewModel: function(params, componentInfo) {
          return new TagsInputModel(params, componentInfo.element);
        }
    },
    template: { element: 'tags-input-template' }
  })

})()