###
HTML5 Number polyfill | Jonathan Stipe | https://github.com/jonstipe/number-polyfill
###
(($) ->
  i = document.createElement "input"
  i.setAttribute "type", "number"
  if i.type == "text"
    $.fn.inputNumber = ->
      $(this).filter ->
        $this = $(this)
        return $this.is('input[type="number"]') and not (
          $this.parent().is("span") &&
          $this.next().is("div.number-spin-btn-container") &&
          $this.next().children().first().is("div.number-spin-btn-up") &&
          $this.next().children().eq(1).is("div.number-spin-btn-down")
        )
      .each ->
        numberPolyfill.polyfills.push(new numberPolyfill(this))
        return
      return $(this)

    numberPolyfill = (elem)->
      @elem = $(elem)
      unless @elem.is(":root *") && @elem.height() > 0
        throw new Error("Element must be in DOM and displayed so that its height can be measured.")
      halfHeight = (@elem.outerHeight() / 2) + 'px'
      @upBtn = $ '<div/>', { class: 'number-spin-btn number-spin-btn-up', style: "height: #{halfHeight}" }
      @downBtn = $ '<div/>', { class: 'number-spin-btn number-spin-btn-down', style: "height: #{halfHeight}" }
      @btnContainer = $ '<div/>', { class: 'number-spin-btn-container' }
      $fieldContainer = $ '<span/>', { style: "white-space: nowrap" }
      @upBtn.appendTo @btnContainer
      @downBtn.appendTo @btnContainer
      @elem.wrap($fieldContainer)
      @btnContainer.insertAfter @elem

      @elem.on
        focus: (e) =>
          @elem.on {
            DOMMouseScroll: numberPolyfill.domMouseScrollHandler
            mousewheel: numberPolyfill.mouseWheelHandler
          }, { p: @ }
          return
        blur: (e) =>
          @elem.off
            DOMMouseScroll: numberPolyfill.domMouseScrollHandler
            mousewheel: numberPolyfill.mouseWheelHandler
          return

      @elem.on {
        keypress: numberPolyfill.elemKeypressHandler
        change: numberPolyfill.elemChangeHandler
      }, { p: @ }

      @upBtn.on "mousedown", { p: @, func: "increment" }, numberPolyfill.elemBtnMousedownHandler
      @downBtn.on "mousedown", { p: @, func: "decrement" }, numberPolyfill.elemBtnMousedownHandler

      @elem.css "textAlign", 'right'
      @attrMutationHandler("class")

      if (WebKitMutationObserver? || MutationObserver?)
        if (WebKitMutationObserver? && not MutationObserver?)
          MutationObserver = WebKitMutationObserver
        attrObserver = new MutationObserver (mutations, observer) =>
          for mutation in mutations
            if mutation.type == "attributes"
              @attrMutationHandler(mutation.attributeName, mutation.oldValue, @elem.attr(mutation.attributeName))
          return
        attrObserver.observe elem, {
          attributes: true
          attributeOldValue: true
          attributeFilter: ["class", "style", "min", "max", "step"]
        }
      else if MutationEvent?
        @elem.on "DOMAttrModified", (evt) =>
          @attrMutationHandler(evt.originalEvent.attrName, evt.originalEvent.prevValue, evt.originalEvent.newValue)
          return
      return

    numberPolyfill.polyfills = []

    numberPolyfill.isNumber = (input) ->
      if (input? && typeof input.toString == "function")
        return /^-?\d+(?:\.\d+)?$/.test(input.toString())
      else
        return false

    numberPolyfill.isFloat = (input) ->
      if (input? && typeof input.toString == "function")
        return /^-?\d+\.\d+$/.test(input.toString())
      else
        return false

    numberPolyfill.isInt = (input) ->
      if (input? && typeof input.toString == "function")
        return /^-?\d+$/.test(input.toString())
      else
        return false

    numberPolyfill.isNegative = (input) ->
      if (input? && typeof input.toString == "function")
        return /^-\d+(?:\.\d+)?$/.test(input.toString())
      else
        return false

    numberPolyfill.raiseNum = (num) ->
      if typeof num == "number" || (typeof num == "object" && num instanceof Number)
        if num % 1
          return { num: num.toString(), precision: 0 }
        else
          return numberPolyfill.raiseNum(num.toString())
      else if typeof num == "string" || (typeof num == "object" && num instanceof String)
        if numberPolyfill.isFloat num
          num = num.replace(/(\.\d)0+$/, "$1")
          nump = numberPolyfill.getPrecision(num)
          numi = (num[0...(-(nump + 1))] + num[(-nump)...])
          numi = numi.replace(/^(-?)0+(\d+)/, "$1$2")
          a = { num: numi, precision: nump }
          return a
        else if numberPolyfill.isInt num
          return { num: num, precision: 0 }

    numberPolyfill.raiseNumPrecision = (rNum, newPrecision) ->
      if rNum.precision < newPrecision
        for i in [rNum.precision...newPrecision]
          rNum.num += "0"
        rNum.precision = newPrecision
      return

    numberPolyfill.lowerNum = (num) ->
      if num.precision > 0
        while num.num.length < (num.precision + 1)
          if numberPolyfill.isNegative num.num
            num.num = num.num[0...1] + "0" + num.num[1...]
          else
            num.num = "0" + num.num
        return (num.num[0...(-num.precision)] + "." + num.num[(-num.precision)...]).replace(/\.?0+$/, '').replace(/^(-?)(\.)/, "$10$2")
      else
        return num.num
        
    numberPolyfill.preciseAdd = (num1, num2) ->
      if (typeof num1 == "number" || (typeof num1 == "object" && num1 instanceof Number)) && (typeof num2 == "number" || (typeof num2 == "object" && num2 instanceof Number))
        if num1 % 1 == 0 && num2 % 1 == 0
          return (num1 + num2).toString()
        else
          return numberPolyfill.preciseAdd(num1.toString(), num2.toString())
      else if (typeof num1 == "string" || (typeof num1 == "object" && num1 instanceof String)) && (typeof num2 == "string" || (typeof num2 == "object" && num2 instanceof String))
        if numberPolyfill.isNumber(num1)
          if numberPolyfill.isNumber(num2)
            if numberPolyfill.isInt(num1)
              if numberPolyfill.isInt(num2)
                return numberPolyfill.preciseAdd(parseInt(num1, 10), parseInt(num2, 10))
              else if numberPolyfill.isFloat(num2)
                num1 += ".0"
            else if numberPolyfill.isFloat(num1)
              if numberPolyfill.isInt(num2)
                num2 += ".0"

            num1i = numberPolyfill.raiseNum num1
            num2i = numberPolyfill.raiseNum num2
            if num1i.precision < num2i.precision
              numberPolyfill.raiseNumPrecision num1i, num2i.precision
            else if num1i.precision > num2i.precision
              numberPolyfill.raiseNumPrecision num2i, num1i.precision
            result = (parseInt(num1i.num, 10) + parseInt(num2i.num, 10)).toString()
            if num1i.precision > 0
              if numberPolyfill.isNegative(result)
                result = "-0" + result[1...] while num1i.precision > (result.length - 1)
              else
                result = "0" + result while num1i.precision > result.length
              result = numberPolyfill.lowerNum({ num: result, precision: num1i.precision })
            result = result.replace(/^(-?)\./, '$10.')
            result = result.replace(/0+$/, '') if numberPolyfill.isFloat(result)
            return result
          else
            throw new SyntaxError("Argument \"#{ num2 }\" is not a number.")
        else
          throw new SyntaxError("Argument \"#{ num1 }\" is not a number.")
      else
        return numberPolyfill.preciseAdd(num1.toString(), num2.toString())

    numberPolyfill.preciseSubtract = (num1, num2) ->
      if (typeof num2 == "number" || (typeof num2 == "object" && num2 instanceof Number))
        return numberPolyfill.preciseAdd(num1, -num2)
      else if (typeof num2 == "string" || (typeof num2 == "object" && num2 instanceof String))
        if numberPolyfill.isNegative(num2)
          return numberPolyfill.preciseAdd(num1, num2[1..])
        else
          return numberPolyfill.preciseAdd(num1, "-" + num2)

    numberPolyfill.getPrecision = (num) ->
      if typeof num == "number"
        k = 0
        kNum = num
        while kNum != Math.floor(kNum)
          kNum = num * Math.pow(10, ++k)
        return k
      else if typeof num == "string"
        if numberPolyfill.isNumber num
          if numberPolyfill.isFloat num
            return /^-?\d+(?:\.(\d+))?$/.exec(num)[1].length
          else
            return 0

    numberPolyfill::getParams = () ->
      step = @elem.attr 'step'
      min = @elem.attr 'min'
      max = @elem.attr 'max'
      val = @elem.val()
      step = null unless numberPolyfill.isNumber(step)
      min = null unless numberPolyfill.isNumber(min)
      max = null unless numberPolyfill.isNumber(max)
      unless numberPolyfill.isNumber(val)
        val = min || 0
      return {
        min: if (min?) then min else null
        max: if (max?) then max else null
        step: if (step?) then step else "1"
        val: if (val?) then val else null
      }

    numberPolyfill::clipValues = (value, min, max) ->
      if max? && parseFloat(value) > parseFloat(max)
        return max
      else if min? && parseFloat(value) < parseFloat(min)
        return min
      else
        return value

    numberPolyfill::stepNormalize = (value) ->
      params = @getParams()
      step = params['step']
      min = params['min']
      if not step?
        return value
      else
        step = numberPolyfill.raiseNum step
        cValue = numberPolyfill.raiseNum value
        if cValue.precision > step.precision
          numberPolyfill.raiseNumPrecision step, cValue.precision
        else if cValue.precision < step.precision
          numberPolyfill.raiseNumPrecision cValue, step.precision
        if min?
          cValue = numberPolyfill.raiseNum(numberPolyfill.preciseSubtract(value, min))
          numberPolyfill.raiseNumPrecision(cValue, step.precision)
        if parseFloat(cValue.num) % parseFloat(step.num) == 0
          return value
        else
          cValue = numberPolyfill.lowerNum { num: ((Math.round(parseFloat(cValue.num) / (sn = parseFloat(step.num))) * sn).toString()), precision: cValue.precision }
          cValue = numberPolyfill.preciseAdd cValue, min if min?
          return cValue

    numberPolyfill.domMouseScrollHandler = (evt) ->
      p = evt.data.p
      evt.preventDefault()
      if evt.originalEvent.detail < 0
        p.increment()
      else
        p.decrement()
      return

    numberPolyfill.mouseWheelHandler = (evt) ->
      p = evt.data.p
      evt.preventDefault()
      if evt.originalEvent.wheelDelta > 0
        p.increment()
      else
        p.decrement()
      return

    numberPolyfill.elemKeypressHandler = (evt) ->
      p = evt.data.p
      if evt.keyCode == 38 # up arrow
        p.increment()
      else if evt.keyCode == 40 # down arrow
        p.decrement()
      else if (evt.keyCode not in [8, 9, 35, 36, 37, 39, 46]) && (evt.which not in [45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57])
        evt.preventDefault()
      return

    numberPolyfill.elemChangeHandler = (evt) ->
      p = evt.data.p
      unless p.elem.val() == ""
        if numberPolyfill.isNumber(p.elem.val())
          params = p.getParams()
  
          newVal = p.clipValues params['val'], params['min'], params['max']
          newVal = p.stepNormalize newVal
  
          if newVal.toString() != p.elem.val()
            p.elem.val(newVal).change()
        else
          min = p.elem.attr('min')
          p.elem.val(if (min? && numberPolyfill.isNumber(min)) then min else "0").change()
      return

    numberPolyfill.elemBtnMousedownHandler = (evt) ->
      p = evt.data.p
      func = evt.data.func
      p[func]()

      timeoutFunc = (incFunc) =>
        p[func]()
        p.timeoutID = window.setTimeout(timeoutFunc, 10)
        return

      releaseFunc = (e) =>
        window.clearTimeout p.timeoutID
        $(document).off 'mouseup', releaseFunc
        $(this).off 'mouseleave', releaseFunc
        return

      $(document).on 'mouseup', releaseFunc
      $(this).on 'mouseleave', releaseFunc

      p.timeoutID = window.setTimeout(timeoutFunc, 700)
      return

    numberPolyfill::attrMutationHandler = (name, oldValue, newValue) ->
      if name == "class" or name == "style"
        h = {}
        ei = null
        for i in ["opacity", "visibility", "-moz-transition-property", "-moz-transition-duration", "-moz-transition-timing-function", "-moz-transition-delay", "-webkit-transition-property", "-webkit-transition-duration", "-webkit-transition-timing-function", "-webkit-transition-delay", "-o-transition-property", "-o-transition-duration", "-o-transition-timing-function", "-o-transition-delay", "transition-property", "transition-duration", "transition-timing-function", "transition-delay"]
          if (ei = @elem.css(i)) != @btnContainer.css(i)
            h[i] = ei
        if (@elem.css("display") == "none")
          h["display"] = "none"
        else
          h["display"] = "inline-block"
        @btnContainer.css(h)
      else if name in ["min", "max", "step"]
        @elem.change()
      return

    numberPolyfill::increment = () ->
      unless @elem.is(":disabled") or @elem.is("[readonly]")

        params = @getParams()
        newVal = numberPolyfill.preciseAdd params['val'], params['step']

        newVal = params['max'] if params['max']? && parseFloat(newVal) > parseFloat(params['max'])
        newVal = @stepNormalize newVal

        @elem.val(newVal).change()
      return

    numberPolyfill::decrement = () ->
      unless @elem.is(":disabled") or @elem.is("[readonly]")

        params = @getParams()
        newVal = numberPolyfill.preciseSubtract params['val'], params['step']

        newVal = params['min'] if params['min']? && parseFloat(newVal) < parseFloat(params['min'])
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
