###
HTML5 Number polyfill | Jonathan Stipe | https://github.com/jonstipe/number-polyfill
###
(($) ->
  i = document.createElement "input"
  i.setAttribute "type", "number"
  if i.type == "text"
    $.fn.inputNumber = ->
      console.log "found #{ $(this).filter('input[type="number"]').length } elements."
      $(this).filter('input[type="number"]').each ->
        console.log "Creating new polyfill."
        numberPolyfill.polyfills.push(new numberPolyfill(this))
        return
      return $(this)
      
    decimalNum = (num, precision)->
      unless precision?
        if typeof num == 'object' && num.constructor == decimalNum
          @num = num.num
          @precision = num.precision
        else if typeof num == 'number' || (typeof num == 'object' && num.constructor == Number)
          rNum = num
          r = 0
          while rNum > Math.floor(rNum)
            rNum = num * Math.pow(10, r++)
          @num = rNum
          @precision = r
      else 
        @num = num
        @precision = precision
      return

    decimalNum::raise = (digits)->
      @num = @num * Math.pow(10, digits)
      @precision += digits
      return

    decimalNum::add = (other_num)->
      other_num = new decimalNum(other_num)
      if @precision > other_num.precision
        other_num.raise(@precision - other_num.precision)
      else if @precision < other_num.precision
        @raise(other_num.precision - @precision)
      sum = new decimalNum(@num + other_num.num, @precision)
      sum.reduce()
      return sum

    decimalNum::subtract = (other_num)->
      other_num = new decimalNum(other_num)
      if @precision > other_num.precision
        other_num.raise(@precision - other_num.precision)
      else if @precision < other_num.precision
        @raise(other_num.precision - @precision)
      diff = new decimalNum(@num - other_num.num, @precision)
      diff.reduce()
      return diff
  
    decimalNum::reduce = ()->
      r = 0
      while @num % Math.pow(10, r) == 0 && r < @precision
        r++
      if r > 0
        @num = @num / Math.pow(10, r)
        @precision -= r
      return
      
    decimalNum::toFloat = ()->
      return (@num / Math.pow(10, @precision))
      
    decimalNum::toString = ()->
      return @toFloat().toString()

    decimalNum::mod = (num)->
      return @toFloat() % num

    numberPolyfill = (elem)->
      @elem = $(elem)
      halfHeight = (@elem.outerHeight() / 2) + 'px'
      @upBtn = $ '<div/>', { class: 'number-spin-btn number-spin-btn-up', style: "height: #{halfHeight}" }
      @downBtn = $ '<div/>', { class: 'number-spin-btn number-spin-btn-down', style: "height: #{halfHeight}" }
      $btnContainer = $ '<div/>', { class: 'number-spin-btn-container' }
      $fieldContainer = $ '<span/>', { style: "white-space: nowrap" }
      @upBtn.appendTo $btnContainer
      @downBtn.appendTo $btnContainer
      @elem.wrap($fieldContainer)
      $btnContainer.insertAfter @elem
      console.log "Added buttons."

      domMouseScrollHandler = (e) =>
        e.preventDefault()
        if e.originalEvent.detail < 0
          @increment()
        else
          @decrement()
        return
        
      mouseWheelHandler = (e) =>
        e.preventDefault()
        if e.originalEvent.wheelDelta > 0
          @increment()
        else
          @decrement()
        return

      console.log "Adding element event handlers."
      @elem.on
        focus: (e) =>
          @elem.on
            DOMMouseScroll: domMouseScrollHandler
            mousewheel: mouseWheelHandler
          return
        blur: (e) =>
          @elem.off
            DOMMouseScroll: domMouseScrollHandler
            mousewheel: mouseWheelHandler
          return
        keypress: (e) =>
          if e.keyCode == 38 # up arrow
            @increment()
          else if e.keyCode == 40 # down arrow
            @decrement()
          else if (e.keyCode not in [8, 9, 35, 36, 37, 39]) && (e.which not in [45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57])
            e.preventDefault()
          return
        change: (e) =>
          if e.originalEvent?
            params = @getParams()

            newVal = @clipValues params['val'], params['min'], params['max']
            newVal = @matchStep newVal, params['min'], params['max'], params['step'], params['stepDecimal']

            @elem.val newVal
          return
  
      console.log "Adding button event handlers."
      @upBtn.on "mousedown", (e) =>
        @increment()

        timeoutFunc = (incFunc) =>
          @increment()
          @timeoutID = window.setTimeout(timeoutFunc, 10)
          return

        releaseFunc = (e) =>
          window.clearTimeout @timeoutID
          $(document).off 'mouseup', releaseFunc
          @upBtn.off 'mouseleave', releaseFunc
          return

        $(document).on 'mouseup', releaseFunc
        @upBtn.on 'mouseleave', releaseFunc

        @timeoutID = window.setTimeout(timeoutFunc, 700)
        return
      @downBtn.on "mousedown", (e) =>
        @decrement()

        timeoutFunc = (decFunc) =>
          @decrement()
          @timeoutID = window.setTimeout(timeoutFunc, 10)
          return

        releaseFunc = (e) =>
          window.clearTimeout @timeoutID
          $(document).off 'mouseup', releaseFunc
          @downBtn.off 'mouseleave', releaseFunc
          return

        $(document).on 'mouseup', releaseFunc
        @downBtn.on 'mouseleave', releaseFunc

        @timeoutID = window.setTimeout(timeoutFunc, 700)
        return
      @elem.css "textAlign", 'right'
      $btnContainer.css("opacity", @elem.css("opacity")) if @elem.css("opacity") != "1"
      $btnContainer.css("visibility", @elem.css("visibility")) if @elem.css("visibility") != "visible"
      #$btnContainer.css("display", @elem.css("display")) if @elem.css("display") != ""
      console.log "Adding mutation observers."
      if (WebKitMutationObserver? || MutationObserver?)
        attrMutationCallback = (mutations, observer) =>
          for mutation in mutations
            if mutation.type == "attributes"
              if mutation.attributeName == "class"
                $btnContainer.removeClass(mutation.oldValue).addClass(@elem.className)
              else if mutation.attributeName == "style"
                $btnContainer.css {
                  "opacity": @elem.css("opacity")
                  "visibility": @elem.css("visibility")
                  "display": @elem.css("display")
                }
          return
        attrObserver = if (WebKitMutationObserver?) then new WebKitMutationObserver(attrMutationCallback) else (if (MutationObserver?) then new MutationObserver(attrMutationCallback) else null)
        attrObserver.observe elem, {
          attributes: true
          attributeOldValue: true
          attributeFilter: ["class", "style"]
        }
      else if MutationEvent?
        @elem.on "DOMAttrModified", (evt) ->
          if evt.originalEvent.attrName == "class"
            $(btnContainer).removeClass(evt.originalEvent.prevValue).addClass(evt.originalEvent.newValue)
          else if evt.originalEvent.attrName == "style"
            $(btnContainer).css {
              "display": elem.style.display
              "visibility": elem.style.visibility
              "opacity": elem.style.opacity
            }
          return
      console.log "Done with one."
      return

    numberPolyfill.polyfills = []
  
    numberPolyfill::getParams = () ->
      step = @elem.attr 'step'
      min = @elem.attr 'min'
      max = @elem.attr 'max'
      val = @elem.val()
      step = null unless /^-?\d+(?:\.\d+)?$/.test(step)
      min = null unless /^-?\d+(?:\.\d+)?$/.test(min)
      max = null unless /^-?\d+(?:\.\d+)?$/.test(max)
      unless /^-?\d+(?:\.\d+)?$/.test(val)
        val = min || 0
      {
        min: new decimalNum(min)
        max: new decimalNum(max)
        step: new decimalNum(step)
        val: new decimalNum(val)
      }

    numberPolyfill::clipValues = (value, min, max) ->
      if max? && value.toFloat() > max.toFloat()
        max
      else if min? && value.toFloat() < min.toFloat()
        min
      else
        value

    numberPolyfill::stepNormalize = (value) ->
      return value
#      params = @getParams()
#      value = params['value']
#      step = params['step']
#      min = params['min']
#      max = params['max']
#      unless step?
#        return value
#      else
#        stepDecimalDigits = numberPolyfill.extractNumDecimalDigits step
#        if stepDecimalDigits == 0
#          raiseTo = Math.pow 10, stepDecimalDigits
#          step = parseFloat(params['step']) * raiseTo
#        else
#          raiseTo = 1
#          step = parseFloat(params['step'])
#        cValue = value
#        cValue = numberPolyfill.subtractAsStr(cValue, min) if min?
#        cValue = (parseFloat(cValue) * raiseTo).toString() if raiseTo > 1
#        mod = cValue % step
        
        
        
      
#       if stepDecimalDigits == 0
#        mod = (value - (min || 0)) % step
#        if mod == 0
#          value;
#        else
#          stepDown = value - mod
#          stepUp = stepDown + step
#          if (stepUp > max) || ((value - stepDown) < (stepUp - value))
#            stepDown
#          else
#            stepUp
#      else
#        raiseTo = Math.pow 10, stepDecimalDigits
#        raisedStep = step * raiseTo
#        raisedMod = (value - (min || 0)) * raiseTo % raisedStep
#        if raisedMod == 0
#          value
#        else
#          raisedValue = value * raiseTo
#          raisedStepDown = raisedValue - raisedMod
#          raisedStepUp = raisedStepDown + raisedStep
#          if ((raisedStepUp / raiseTo) > max) || ((raisedValue - raisedStepDown) < (raisedStepUp - raisedValue))
#            raisedStepDown / raiseTo
#          else
#            raisedStepUp / raiseTo

#    numberPolyfill.addAsStr = (str1, str2) ->
#      isFloat = /^-?\d+(?:\.\d+)?$/
#      isInt = /^-?\d+$/
#      isNegative = /^-.+$/
#      if isFloat.test(str1) &&  isFloat.test(str2)
#        if isInt.test(str1)
#          if isInt.test(str2)
#            return (parseInt(str1, 10) + parseInt(str2, 10)).toString()
#          else
#            return numberPolyfill.addAsStr(str1 + ".0", str2)
#        else
#          if isInt.test(str2)
#            return numberPolyfill.addAsStr(str1, str2 + ".0")
#          else
#            precision1 = str1.length - str1.indexOf(".") - 1
#            precision2 = str2.length - str2.indexOf(".") - 1
#            add = true
#            output = ""
#            k = 0
#            carry = 0
#            digit = 0
#            if precision1 < precision2
#              for i in [0...(precision2-precision1)]
#                str1 = str1 + "0"
#            else if precision2 < precision1
#              for i in [0...(precision1-precision2)]
#                str2 = str2 + "0"
#            if (isNegative.test(str1) && !isNegative.test(str2)) || (!isNegative.test(str1) && isNegative.test(str2))
#              add = false
#            while (k < str1.length && k < str2.length) || carry != 0
#              digit1 = if k < str1.length then str1[(str1.length - 1) - k] else "0"
#              digit2 = if k < str2.length then str2[(str2.length - 1) - k] else "0"
#              digit1 = "0" if digit1 == "-"
#              digit2 = "0" if digit2 == "-"
#              if digit1 == "." && digit2 == "."
#                output = "." + output
#              else
#                digit1 = parseInt(digit1, 10)
#                digit2 = parseInt(digit2, 10)
#                if add
#                  digit = digit1 + digit2 + carry
#                else
#                  digit = digit1 - digit2 - carry
#                carry = Math.floor(digit / 10)
#                output = (digit % 10).toString() + output
#              k++
#            if isNegative.test(str1)
#              if isNegative.test(str2) || (parseInt(str2, 10) < Math.abs(parseInt(str1, 10)))
#                output = "-" + output
#            else
#              if isNegative.test(str2) && (Math.abs(parseInt(str2, 10)) > parseInt(str1, 10))
#                output = "-" + output
#            return output

#    numberPolyfill.subtractAsStr = (str1, str2) ->
#      isNegative = /^-.+$/
#      if isNegative.test(str2)
#        return numberPolyfill.addAsStr(str1, str2[1...])
#      else
#        return numberPolyfill.addAsStr(str1, "-" + str2)
          
    numberPolyfill::increment = () ->
      unless @elem.is(":disabled")
        console.log "increment() called."
        params = @getParams()
        newVal = params['val'].add params['step']
  
        newVal = params['max'] if params['max']? && newVal.toFloat() > params['max'].toFloat()
        newVal = @stepNormalize newVal
  
        @elem.val(newVal).change()
      return

    numberPolyfill::decrement = () ->
      unless @elem.is(":disabled")
        console.log "decrement() called."
        params = @getParams()
        newVal = params['val'].subtract params['step']
  
        newVal = params['min'] if params['min']? && newVal.toFloat() < params['min'].toFloat()
        newVal = @stepNormalize newVal
  
        @elem.val(newVal).change()
      return

  else
    $.fn.inputNumber = ->
      $(this)
    return
  
  $ ->
    $('input[type="number"]').inputNumber()
    return
  return
)(jQuery)
