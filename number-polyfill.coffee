###
HTML5 Number polyfill | Jonathan Stipe | https://github.com/jonstipe/number-polyfill
###
(($) ->
  i = document.createElement "input"
  i.setAttribute "type", "number"
  if i.type == "text"
    $.fn.inputNumber = ->
      getParams = (elem) ->
        $elem = $ elem
        step = $elem.attr 'step'
        min = $elem.attr 'min'
        max = $elem.attr 'max'
        val = parseFloat $elem.val()
        step = if /^-?\d+(?:\.\d+)?$/.test(step) then parseFloat(step) else null
        min = if /^-?\d+(?:\.\d+)?$/.test(min) then parseFloat(min) else null
        max = if /^-?\d+(?:\.\d+)?$/.test(max) then parseFloat(max) else null
        if isNaN val
          val = min || 0
        {
          min: min
          max: max
          step: step
          val: val
        }

      clipValues = (value, min, max) ->
        if max? && value > max
          max
        else if min? && value < min
          min
        else
          value

      extractNumDecimalDigits = (input) ->
        if input?
          num = 0
          raisedNum = input
          while raisedNum != Math.round raisedNum
            num += 1
            raisedNum = input * Math.pow(10, num)
          num
        else
          0

      matchStep = (value, min, max, step) ->
        stepDecimalDigits = extractNumDecimalDigits step
        unless step?
          value
        else if stepDecimalDigits == 0
          mod = (value - (min || 0)) % step
          if mod == 0
            value;
          else
            stepDown = value - mod
            stepUp = stepDown + step
            if (stepUp > max) || ((value - stepDown) < (stepUp - value))
              stepDown
            else
              stepUp
        else
          raiseTo = Math.pow 10, stepDecimalDigits
          raisedStep = step * raiseTo
          raisedMod = (value - (min || 0)) * raiseTo % raisedStep
          if raisedMod == 0
            value
          else
            raisedValue = value * raiseTo
            raisedStepDown = raisedValue - raisedMod
            raisedStepUp = raisedStepDown + raisedStep
            if ((raisedStepUp / raiseTo) > max) || ((raisedValue - raisedStepDown) < (raisedStepUp - raisedValue))
              raisedStepDown / raiseTo
            else
              raisedStepUp / raiseTo

      increment = (elem) ->
        unless $(elem).is(":disabled")
          params = getParams elem
          raiseTo = Math.pow 10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step']))
          newVal = (Math.round(params['val'] * raiseTo) + Math.round((params['step'] || 1) * raiseTo)) / raiseTo

          newVal = params['max'] if params['max']? && newVal > params['max']
          newVal = matchStep newVal, params['min'], params['max'], params['step']

          $(elem).val(newVal).change()
        null

      decrement = (elem) ->
        unless $(elem).is(":disabled")
          params = getParams elem
          raiseTo = Math.pow 10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step']))
          newVal = (Math.round(params['val'] * raiseTo) - Math.round((params['step'] || 1) * raiseTo)) / raiseTo

          newVal = params['min'] if params['min']? && newVal < params['min']
          newVal = matchStep newVal, params['min'], params['max'], params['step']

          $(elem).val(newVal).change()
        null

      domMouseScrollHandler = (e) ->
        e.preventDefault()
        if e.originalEvent.detail < 0
          increment this
        else
          decrement this
        null
      mouseWheelHandler = (e) ->
        e.preventDefault()
        if e.originalEvent.wheelDelta > 0
          increment this
        else
          decrement this
        null

      $(this).filter('input[type="number"]').each ->
        elem = this
        $elem = $(elem)
        halfHeight = ($elem.outerHeight() / 2) + 'px'
        upBtn = document.createElement 'div'
        downBtn = document.createElement 'div'
        $upBtn = $ upBtn
        $downBtn = $ downBtn
        btnContainer = document.createElement 'div'
        $upBtn
          .addClass('number-spin-btn number-spin-btn-up')
          .css('height', halfHeight)
        $downBtn
          .addClass('number-spin-btn number-spin-btn-down')
          .css('height', halfHeight)
        btnContainer.appendChild upBtn
        btnContainer.appendChild downBtn
        $(btnContainer).addClass('number-spin-btn-container').insertAfter elem

        $elem.on
          focus: (e) ->
            $elem.on
              DOMMouseScroll: domMouseScrollHandler
              mousewheel: mouseWheelHandler
            null
          blur: (e) ->
            $elem.off
              DOMMouseScroll: domMouseScrollHandler
              mousewheel: mouseWheelHandler
            null
          keypress: (e) ->
            if e.keyCode == 38 # up arrow
              increment this
            else if e.keyCode == 40 # down arrow
              decrement this
            else if (e.keyCode not in [8, 9, 35, 36, 37, 39, 46]) && (e.which not in [45, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57])
              e.preventDefault()
            null
          change: (e) ->
            if e.originalEvent?
              params = getParams this

              newVal = clipValues params['val'], params['min'], params['max']
              newVal = matchStep newVal, params['min'], params['max'], params['step'], params['stepDecimal']

              $(this).val newVal
            null

        $upBtn.on "mousedown", (e) ->
          increment elem

          timeoutFunc = (elem, incFunc) ->
            incFunc elem
            $elem.data "timeoutID", window.setTimeout(timeoutFunc, 10, elem, incFunc)
            null

          releaseFunc = (e) ->
            window.clearTimeout $elem.data("timeoutID")
            $(document).off 'mouseup', releaseFunc
            $upBtn.off 'mouseleave', releaseFunc
            null

          $(document).on 'mouseup', releaseFunc
          $upBtn.on 'mouseleave', releaseFunc

          $elem.data "timeoutID", window.setTimeout(timeoutFunc, 700, elem, increment)
          null
        $downBtn.on "mousedown", (e) ->
          decrement elem

          timeoutFunc = (elem, decFunc) ->
            decFunc elem
            $elem.data "timeoutID", window.setTimeout(timeoutFunc, 10, elem, decFunc)
            null

          releaseFunc = (e) ->
            window.clearTimeout $elem.data("timeoutID")
            $(document).off 'mouseup', releaseFunc
            $downBtn.off 'mouseleave', releaseFunc
            null

          $(document).on 'mouseup', releaseFunc
          $downBtn.on 'mouseleave', releaseFunc

          $elem.data "timeoutID", window.setTimeout(timeoutFunc, 700, elem, decrement)
          null
        $elem.css "textAlign", 'right'
        $(btnContainer).css("opacity", $elem.css("opacity")) if $elem.css("opacity") != "1"
        $(btnContainer).css("visibility", $elem.css("visibility")) if $elem.css("visibility") != "visible"
        $(btnContainer).css("display", $elem.css("display")) if elem.style.display != ""
        if (WebKitMutationObserver? || MutationObserver?)
          attrMutationCallback = (mutations, observer) ->
            (
              if mutation.type == "attributes"
                if mutation.attributeName == "class"
                  $(btnContainer).removeClass(mutation.oldValue).addClass(elem.className)
                else if mutation.attributeName == "style"
                  $(btnContainer).css {
                    "opacity": elem.style.opacity
                    "visibility": elem.style.visibility
                    "display": elem.style.display
                  }
            ) for mutation in mutations
            null
          attrObserver = if (WebKitMutationObserver?) then new WebKitMutationObserver(attrMutationCallback) else (if (MutationObserver?) then new MutationObserver(attrMutationCallback) else null)
          attrObserver.observe elem, {
            attributes: true
            attributeOldValue: true
            attributeFilter: ["class", "style"]
          }
        else if MutationEvent?
          $elem.on "DOMAttrModified", (evt) ->
            if evt.originalEvent.attrName == "class"
              $(btnContainer).removeClass(evt.originalEvent.prevValue).addClass(evt.originalEvent.newValue)
            else if evt.originalEvent.attrName == "style"
              $(btnContainer).css {
                "display": elem.style.display
                "visibility": elem.style.visibility
                "opacity": elem.style.opacity
              }
            null
        null
      $(this)
    $ ->
      $('input[type="number"]').inputNumber()
      null
    null
  else
    $.fn.inputNumber = ->
      $(this)
    null
  null
)(jQuery)
