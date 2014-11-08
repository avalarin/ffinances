AvDropdown = (function() {
  var clickEvent = 'click.av-dropdown'
  var focusoutEvent = 'focusout.av-dropdown'
  var keydownEvent = 'keydown.av-dropdown'
  var keypressEvent = 'keypress.av-dropdown'
  var dropdowns = []

  function AvDropdown(element, options) {
    options = options || {}
    dropdowns.push(this)
    var dropdown = this
    var $element = $(element)
    var shown = false
    var toggle = $element.find('[data-toggle=av-dropdown]')
    var drop = $element.find('.av-dropdown-drop')
    var lastFocusedElement

    function attachHandlers() {
      toggle.on(clickEvent, function(event) {
        dropdown.hide()
        return false
      })
      $element.on(clickEvent, function(event) {
        event.stopPropagation()
      })
      $(document).on(clickEvent, function(event) {
        dropdown.hide()
        return false
      }).on(keydownEvent, function(event) {
        var keyCode = event.keyCode
        if (keyCode == 27) { // escape
          dropdown.hide()
        } else if (keyCode == 8) { // backspace
          if (!$(event.target).is('.search')) {
            $element.find('.search').focus()
          } else {
            return true
          }
        } else if (keyCode == 38 || keyCode == 40) { // up/down
          var items = drop.find('.select-list li:not(.divider):visible a')
          var index = items.index(items.filter(':focus'))
          if (keyCode == 38 && index > 0) index--
          if (keyCode == 40 && index < items.length - 1) index++
          if (!~index) index = 0
          items.eq(index).trigger('focus')
        }
        else {
          return true
        }
        return false
      }).on(keypressEvent, function(event) {
        $element.find('.search').focus()
      })
    }

    function detachHandlers() {
      toggle.off(clickEvent)
      $element.off(clickEvent)
      $(document).off(clickEvent).off(keydownEvent).off(keypressEvent)
    }

    dropdown.show = function() {
      if (shown) return
      _.each(dropdowns, function(dd) {
        dd.hide(true)
      })
      lastFocusedElement = $(':focus')
      $element.addClass('open')
      toggle.addClass('active')
      attachHandlers()
      if (options['onshow']) options['onshow']()
      shown = true
    }

    dropdown.hide = function(nofocus) {
      if (!shown) return
      $element.removeClass('open')
      toggle.removeClass('active')
      detachHandlers()
      if (lastFocusedElement && !nofocus) {
        lastFocusedElement.focus()
      }
      if (options['onhide']) options['onhide']()
      shown = false
    }

    toggle.on('click', dropdown.show).on('keydown', function(event) {
        var keyCode = event.keyCode
        if (keyCode == 40) {
          dropdown.show()
        }
      }).on('keypress', function(event) {
        dropdown.show()
        $element.find('.search').focus()
      })
  }

  AvDropdown.attach = function(element, options) {
    var dropdown = new AvDropdown(element, options)
    $(element).data('av-dropdown', dropdown)
    return dropdown
  }

  return AvDropdown
})()


