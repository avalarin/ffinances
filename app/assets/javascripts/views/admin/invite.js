//= require knockout
//= require modules/http
//= require modules/messages
//= require modules/modals
//= require controls/page
//= require controls/datatable
//= require controls/modal

(function() {

  var invitesPath = '/admin/invite'

  var http = require('http')
  var messages = require('messages')
  var modals = require('modals')

  var page = new Page()
  var datatable = new Datatable(invitesPath + ".json")
  
  datatable.create = function() {
    http.request({
      url: invitesPath + ".json",
      type: "POST",
      success: function(data) {
        datatable.refresh()
        messages.success(window.localization.inviteCreated)
      }
    })
  }

  datatable.delete = function() {
    http.request({
      url: invitesPath + "/" + this.code + ".json",
      type: "DELETE",
      success: function(data) {
        datatable.refresh()
        messages.success(window.localization.inviteDeleted)
      }
    })
  }

  datatable.showLink = function() {
    $('#show-link-modal').modal('show').find('input[name=link]').val(this.link)
  }

  page.addControl('datatable', datatable)

  page.attach()
  datatable.refresh()

})()