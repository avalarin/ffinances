//= require jquery-fileapi
//= require jquery.Jcrop

function AvatarCropper(options) {
  var cropper = this;
  var $modal = $('#avatar-cropper-modal')
  var $modalBody = $modal.find('.modal-body')
  var jcrop
  var currentFile
  var currentCoords
  var originalSize = []
  var cropperSoze = []

  options = options || {}

  function getSelection(w, h) {
    var s = Math.min(w, h)
    var x = 0
    var y = 0
    if (w > h) {
      x = (w / 2 - s / 2)
    } else {
      y = (h / 2 - s / 2)
    }
    return [x, y, x + s, y + s]
  }

  cropper.crop = function(file, size) {
    currentFile = file
    originalSize = size
    $modal.modal('show')
  }

  $modal.on('shown.bs.modal', function() {
    FileAPI.readAsDataURL(currentFile, function (evt/**Object*/){
      if(evt.type == 'load'){
        target = $modalBody.find('.cropper-target')
                    .css({maxWidth: $modalBody.width()})
                    .attr('src', evt.result)
        cropperSize = [ target.width(), target.height() ]
        cropper.jcrop = $.Jcrop(target, {
          allowSelect: false,
          aspectRatio: 1,
          setSelect: getSelection(target.width(), target.height()),
          onSelect: function (coords){
            currentCoords = coords
          }
        })
      }
    })
  }).on('hidden.bs.modal', function() {
    cropper.jcrop.destroy()
    $modalBody.html('<img class="cropper-target"/>')
  }).on('click', '.btn-save', function() {
    if (options['success']) {
      var coords = currentCoords
      var rx = originalSize[0] / cropperSize[0]
      var ry = originalSize[1] / cropperSize[1]
      var ncoords = {
        x: Math.round(coords.x * rx),
        y: Math.round(coords.y * ry),
        w: Math.round(coords.w * rx),
        h: Math.round(coords.h * ry)
      }
      options['success'](currentFile, ncoords)
    }
    $modal.modal('hide')
  })

}

function showAvatarMessage(name) {
  var msg = avatarMessages[name]
  $('.avatar-upload-message')
    .removeClass('text-muted text-success text-danger')
    .addClass('text-' + msg.style)
    .text(msg.text)
}

$(function() {
  var $uploader = $('.avatar-uploader')
  var $btn = $uploader.find('.btn-upload')
  var $input = $('input[name=avatar]')

  $input.width($btn.outerWidth())
  $input.height($btn.outerHeight())

  var cropper = new AvatarCropper({
    success: function(file, coords) {
      FileAPI.upload({
        url: routes.uploadAvatar(),
        data: {
          coords: coords,
          authenticity_token: $("meta[name='csrf-token']").attr("content")
        },
        files: { avatar: file },
        upload: function() {
          $btn.addClass('loading disabled')
        },
        complete: function(err, xhr) {
          $btn.removeClass('loading disabled')
          if (err) {
            showAvatarMessage('error_upload')
            return
          }
          var resp = JSON.parse(xhr.response)
          $uploader.find('img.avatar').attr({ src: resp.data.avatar })
          showAvatarMessage('success')
        }
      })
    }
  })
  $input.on('change', function(event) {
    var file = FileAPI.getFiles(event)[0]
    if(!/^image/.test(file.type)) {
      showAvatarMessage('error_file_type')
      return
    }
    if (file.size > 2*1024*1024) { // 2M
      showAvatarMessage('error_file_size')
      return
    }
    FileAPI.getInfo(file, function (err/**String*/, info/**Object*/){
      if (err) {
        showAvatarMessage('error_read')
        return
      }
      if (info.width < 64 || info.height < 64) {
        showAvatarMessage('error_image_size')
        return
      }
      showAvatarMessage('wait')
      cropper.crop(file, [ info.width, info.height ])
    })
  })
})