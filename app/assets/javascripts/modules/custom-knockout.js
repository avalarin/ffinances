//= require knockout

ko.bindingHandlers.loading = {
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
    },
    update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
      $(element).toggleClass('loading disabled', ko.unwrap(valueAccessor()))
    }
}


ko.bindingHandlers.disabled = {
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
    },
    update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
      $(element).toggleClass('disabled', ko.unwrap(valueAccessor()))
    }
}