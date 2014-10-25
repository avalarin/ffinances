//= require custom-knockout
//= require zeroclipboard
//= require modules/http
//= require modules/messages
//= require modules/modals
//= require controls/page
//= require controls/datatable
//= require controls/modal

(function() {

  $(function() {
    ZeroClipboard.config({
      hoverClass: "hover",
      activeClass: "active"
    });
    var clip = new ZeroClipboard($('.btn-copy'))
  })

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
    var modal = $('#show-link-modal').modal('show')
    modal.find('input[name=link]').val(this.link)
    modal.find('.btn-copy').attr('data-clipboard-text', this.link)
  }

  page.addControl('datatable', datatable)

  page.attach()
  datatable.refresh()

})()