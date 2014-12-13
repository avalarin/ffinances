function Pagination() {
  var pagination = this

  pagination.page = ko.observable(1)
  pagination.perPage = ko.observable(0)
  pagination.totalPages = ko.observable(0)
  pagination.totalItems = ko.observable(0)

  pagination.startItem = ko.computed(function() {
    return ((pagination.page() - 1) * pagination.perPage()) + 1
  })

  pagination.endItem = ko.computed(function() {
    return Math.min(pagination.startItem() + pagination.perPage() - 1, pagination.totalItems())
  })

  pagination.canPrev = ko.computed(function() {
    return pagination.page() > 1
  })

  pagination.canNext = ko.computed(function() {
    return pagination.page() < pagination.totalPages()
  })

  pagination.goPrev = function() {
    if (pagination.canPrev()) pagination.page(pagination.page() - 1)
  }

  pagination.goNext = function() {
    if (pagination.canNext()) pagination.page(pagination.page() + 1)
  }

  pagination.update = function(data) {
    data = data || {}
    if (data.page) pagination.page(data.page)
    if (data.perPage) pagination.perPage(data.perPage)
    if (data.totalPages) pagination.totalPages(data.totalPages)
    if (data.totalItems) pagination.totalItems(data.totalItems)
  }

}