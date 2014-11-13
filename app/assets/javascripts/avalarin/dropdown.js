(function() {
  var clickEvent = 'click.av-dropdown'
  var focusoutEvent = 'focusout.av-dropdown'
  var keydownEvent = 'keydown.av-dropdown'
  var keypressEvent = 'keypress.av-dropdown'

  var dropSelector = '.av-dropdown-drop'
  var toggleSelector   = '[data-toggle=av-dropdown]'

  function AvDropdown(element) {
    $(element).find(toggleSelector).on(clickEvent, this.toggle)
  }

  AvDropdown.prototype.hide = function(e) {
    hide(this)
  }

  AvDropdown.prototype.show = function(e) {
    show(this)
  }

  AvDropdown.prototype.toggle = function(e) {
    var isActive = getRoot($(this)).hasClass('open')
    hideAll()
    if (!isActive) show(this)
    return false;
  }

  AvDropdown.prototype.keydown = function(e) {
    var active = getActive()
    if (!active.length || active.is('.disabled, :disabled')) return
    var root = getRoot(active)
    var isActive = root.hasClass('open')
    if (e.isDefaultPrevented()) return

    var keyCode = e.keyCode
    if (keyCode == 27) { // escape
      hideAll()
    } else if (keyCode == 8) { // backspace
      if (!$(e.target).is('.search')) {
        root.find('.search').focus()
      } else {
        return true
      }
    } else if (keyCode == 38 || keyCode == 40) { // up/down
      var items = root.find('.select-list li:not(.divider):visible a')
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
  }

  AvDropdown.prototype.keypress = function() {
    var active = getActive()
    if (!active.length || active.is('.disabled, :disabled')) return
    var root = getRoot(active)
    var isActive = root.hasClass('open')
    if (e.isDefaultPrevented() || !isActive) return
    root.find('.search').focus()
  }

  function hide(elm) {
    var $elm = $(elm)
    if ($elm.is('.disabled, :disabled')) return
    var root = getRoot($elm)
    var isActive = root.hasClass('open')

    if (!isActive) return

    var relatedTarget = { relatedTarget: elm }
    var e = $.Event('hide.av.dropdown', relatedTarget)
    root.trigger(e)
    if (e.isDefaultPrevented()) return

    root.removeClass('open').trigger('hidden.av.dropdown', relatedTarget)
  }

  function hideAll() {
    $('.av-dropdown').each(function() { hide(this) })
  }

  function show(elm) {
    var $elm = $(elm)
    if ($elm.is('.disabled, :disabled')) return
    var root = getRoot($elm)
    var isActive = root.hasClass('open')

    if (isActive) return

    var relatedTarget = { relatedTarget: this }
    root.trigger(e = $.Event('show.av.dropdown', relatedTarget))
    if (e.isDefaultPrevented()) return

    root.toggleClass('open').trigger('shown.av.dropdown', relatedTarget)
    var drop = root.find(dropSelector).focus()
  }

  function getRoot(elm) {
    return elm.closest('.av-dropdown')
  }

  function getActive() {
    return $('.av-dropdown.open')
  }

  function Plugin(option) {
    return this.each(function () {
      var $this = $(this)
      var data  = $this.data('av.dropdown')

      if (!data) $this.data('av.dropdown', (data = new AvDropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.avDropdown = Plugin
  $.fn.avDropdown.Constructor = AvDropdown

  $(document)
    .on(clickEvent, hideAll)
    .on(clickEvent, '.av-dropdown .av-dropdown-drop', function (e) { e.stopPropagation() })
    .on(clickEvent, toggleSelector, AvDropdown.prototype.toggle)
    .on(keydownEvent, AvDropdown.prototype.keydown)
    .on(keypressEvent, AvDropdown.prototype.keypress)

  $('.av-dropdown').avDropdown()

})()