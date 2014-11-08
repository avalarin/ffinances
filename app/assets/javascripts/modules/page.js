 (function() {
  function Page() {
    this.controls = { }
  }

  Page.prototype.addControl = function(name, control) {
    this.controls[name] = control
  }

  Page.prototype.attach = _.once(function() {
    ko.applyBindings(this.controls)
  })


  window.page = new Page()
  $(function() {
    window.page.attach()
  })
})()