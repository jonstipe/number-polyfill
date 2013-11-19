(($) ->
  ui = {
    typeIn: (elem, txt) ->
      $elem = $(elem)
      len = txt.length
      $elem.focus()
      for i in [0...txt.length]
        code = txt.charCodeAt i
        $elem.trigger(jQuery.Event("keydown", { charCode: code, keyCode: code, which: code }))
        $elem.trigger(jQuery.Event("keyup", { charCode: code, keyCode: code, which: code }))
        $elem.trigger(jQuery.Event("keypress", { charCode: code, keyCode: code, which: code }))
      $elem.blur()
      $elem.val(txt).change() if $elem.val() != txt
      return

    click: (elem, times = 1) ->
      $elem = $(elem)
      for i in [0...times]
        $elem.trigger("mousedown")
        $elem.trigger("mouseup")
        $elem.trigger("click")
      return
  
    mousewheelup: (elem, times = 1) ->
      $elem = $(elem)
      $elem.focus()
      for i in [0...times]
        $elem.trigger(jQuery.Event("mousewheel", { originalEvent: { wheelDelta: 3 } }))
      $elem.blur()
      return
  
    mousewheeldown: (elem, times = 1) ->
      $elem = $(elem)
      $elem.focus()
      for i in [0...times]
        $elem.trigger(jQuery.Event("mousewheel", { originalEvent: { wheelDelta: -3 } }))
      $elem.blur()
      return
  
  }
  
  $numberField = null
  $upBtn = null
  $downBtn = null
  $fixture = $("#qunit-fixture")

  QUnit.testStart (details) ->
    $fixture.append('<input id="myFixture" name="number" type="number" />')
    $fixture.children().inputNumber()
    $numberField = $('#myFixture')
    $upBtn = $('#myFixture + div.number-spin-btn-container > div.number-spin-btn-up')
    $downBtn = $('#myFixture + div.number-spin-btn-container > div.number-spin-btn-down')
    return
    
  test "adds the necessary elements around the field", 6, ->
    ok $numberField.parent().is('span'), "Element is in a span."
    ok $numberField.next().is('div'), "Element is followed by a button container div."
    ok $numberField.next().is('div.number-spin-btn-container'), "Button container div has class 'number-spin-btn-container'."
    equal $numberField.next().children().length, 2, "Button container div has two children."
    ok $numberField.next().children().first().is('div.number-spin-btn-up'), "Button container div's first child has class 'number-spin-btn-up'."
    ok $numberField.next().children().eq(1).is('div.number-spin-btn-down'), "Button container div's second child has class 'number-spin-btn-down'."
    return
  
  test "does not apply multiple times to the same element", 1, ->
    oSrc = $numberField.parent().parent().html()
    $numberField.inputNumber()
    equal $numberField.parent().parent().html(), oSrc, "HTML is not changed when plugin is applied twice."
    return
    
  test "throws an error if element is not attached to the DOM.", 1, ->
    throws ->
      $("<input/>", { type: "number" }).inputNumber()
      return
    , Error
    , "throws an error"
    return

  test "throws an error if element is in an undisplayed element.", 1, ->
    $fixture.empty()
    $fixture.css("display", "none")
    $fixture.append('<input id="myFixture" name="number" type="number" />')
    
    throws ->
      $fixture.children().inputNumber()
      return
    , Error
    , "throws an error"
    
    $fixture.css("display", "")
    return
  
  test "allows values to be typed in", 1, ->
    ui.typeIn $numberField, "12345"
    equal $numberField.val(), "12345", "Field value changes."
    return

  test "doesn't allow non-numeric values", 4, ->
    changeEvents = 0
    $numberField.val "0"
    $numberField.change (evt)->
      changeEvents++
    ui.typeIn $numberField, "AAAAA"
    equal changeEvents, 2, "Change event has fired twice."
    equal $numberField.val(), "0", "Field value changes back to zero after typing letters in."
    $numberField.val("BBBBBB").change()
    equal changeEvents, 4, "Change event has fired four times."
    equal $numberField.val(), "0", "Field value changes back to zero after trying to set the property to letters."
    return
  
  test "doesn't allow values lower than min", 1, ->
    $numberField.attr "min", "10"
    $numberField.val("5").change()
    equal $numberField.val(), "10", "Field value changes to min."
    return
  
  test "allows changing min", 4, ->
    $numberField.attr "min", "10"
    $numberField.val("15").change()
    $numberField.attr "min", "20"
    equal $numberField.val(), "20", "Field value changes to min when min is changed to higher than value."
    $numberField.val("15").change()
    equal $numberField.val(), "20", "Field value changes back to min after being set to lower than min."
    $numberField.attr "min", "10"
    equal $numberField.val(), "20", "Field value doesn't change when min decreases."
    $numberField.val("15").change()
    equal $numberField.val(), "15", "Field value doesn't change to min when set to higher than min."
    return
  
  test "allows deleting min", 3, ->
    $numberField.attr "min", "10"
    $numberField.val("1").change()
    equal $numberField.val(), "10", "Field value changes to min after being set below min."
    $numberField.removeAttr "min"
    $numberField.val("1").change()
    equal $numberField.val(), "1", "Field value can be set after min is deleted."
    $numberField.attr "min", "10"
    equal $numberField.val(), "10", "Field value changes to min after min is restored."
    return
  
  test "doesn't allow values higher than max", 1, ->
    $numberField.attr("max", "100")
    $numberField.val("110").change()
    equal $numberField.val(), "100", "Field value changes to max."
    return
  
  test "allows changing max", 4, ->
    $numberField.attr "max", "150"
    $numberField.val("120").change()
    $numberField.attr "max", "100"
    equal $numberField.val(), "100", "Field value changes to max when max is changed to lower than value."
    $numberField.val("120").change()
    equal $numberField.val(), "100", "Field value changes back to max after being set to higher than max."
    $numberField.attr "max", "150"
    equal $numberField.val(), "100", "Field value doesn't change when max increases."
    $numberField.val("120").change()
    equal $numberField.val(), "120", "Field value doesn't change to max when set to lower than max."
    return
  
  test "allows deleting max", 3, ->
    $numberField.attr "max", "100"
    $numberField.val("100000").change()
    equal $numberField.val(), "100", "Field value changes to max after being set above max."
    $numberField.removeAttr "max"
    $numberField.val("100000").change()
    equal $numberField.val(), "100000", "Field value can be set after max is deleted."
    $numberField.attr "max", "100"
    equal $numberField.val(), "100", "Field value changes to max after max is restored."
    return
    
  test "applies opacity style properties gained from a class attribute to the button container", 3, ->
    $numberField.addClass "opacityZero"
    equal $upBtn.parent().css("opacity"), 0, "Button container is now transparent."
    $numberField.removeClass("opacityZero").addClass "opacityHalf"
    equal $upBtn.parent().css("opacity"), 0.5, "Button container is now translucent."
    $numberField.removeClass("opacityHalf").addClass "opacityOne"
    equal $upBtn.parent().css("opacity"), 1, "Button container is now opaque."
    return
  
  test "applies opacity style properties gained from a style attribute to the button container", 3, ->
    $numberField.css "opacity", "0"
    equal $upBtn.parent().css("opacity"), "0", "Button container is now transparent."
    $numberField.css "opacity", "0.5"
    equal $upBtn.parent().css("opacity"), "0.5", "Button container is now translucent."
    $numberField.css "opacity", "1"
    equal $upBtn.parent().css("opacity"), "1", "Button container is now opaque."
    return
    
  test "applies visibility style properties gained from a class attribute to the button container", 2, ->
    $numberField.addClass "hiddenClass"
    equal $upBtn.parent().css("visibility"), "hidden", "Button container is now hidden."
    $numberField.removeClass "hiddenClass"
    equal $upBtn.parent().css("visibility"), "visible", "Button container is now visible."
    return
    
  test "applies visibility style properties gained from a style attribute to the button container", 2, ->
    $numberField.css "visibility", "hidden"
    equal $upBtn.parent().css("visibility"), "hidden", "Button container is now hidden."
    $numberField.css "visibility", "visible"
    equal $upBtn.parent().css("visibility"), "visible", "Button container is now visible."
    return
    
  test "applies display style properties gained from a class attribute to the button container", 2, ->
    $numberField.addClass "noneClass"
    equal $upBtn.parent().css("display"), "none", "Button container is now hidden."
    $numberField.removeClass "noneClass"
    equal $upBtn.parent().css("display"), "inline-block", "Button container is now visible."
    return
    
  test "applies display style properties gained from a style attribute to the button container", 2, ->
    $numberField.css "display", "none"
    equal $upBtn.parent().css("display"), "none", "Button container is now hidden."
    $numberField.css "display", "inline"
    equal $upBtn.parent().css("display"), "inline-block", "Button container is now visible."
    return
  
  test "can be disabled", 4, ->
    $numberField.val "1"
    $numberField.attr "disabled", "disabled"
    ui.mousewheelup($numberField)
    equal $numberField.val(), "1", "Value does not change with mousewheel up while disabled."
    ui.mousewheeldown($numberField)
    equal $numberField.val(), "1", "Value does not change with mousewheel down while disabled."
    ui.click($upBtn)
    equal $numberField.val(), "1", "Value does not change from clicking the up button while disabled."
    ui.click($downBtn)
    equal $numberField.val(), "1", "Value does not change from clicking the down button while disabled."
    return
  
  test "constrains values with the step attribute", 3, ->
    $numberField.attr "step", "5"
    ui.typeIn $numberField, "40"
    equal $numberField.val(), "40", "Does not change value when in step."
    ui.typeIn $numberField, "42"
    equal $numberField.val(), "40", "Rounds down to the nearest value in step."
    ui.typeIn $numberField, "43"
    equal $numberField.val(), "45", "Rounds up to the nearest value in step."
    return
  
  test "can use fractional steps", ->
    $numberField.attr "step", "0.05"
    
    for rounded, vals of {
      "-10":   ["-10", "-9.99", "-9.98", "-9.976"]
      "-9.95": ["-9.975", "-9.97", "-9.96", "-9.95", "-9.94", "-9.93", "-9.926"]
      "-0.05": ["-0.075", "-0.06", "-0.05", "-0.04", "-0.03", "-0.026"]
      "0":     ["-0.025", "-0.02", "-0.01", "0", "0.01", "0.02", "0.024"]
      "0.05":  ["0.025", "0.03", "0.04", "0.05", "0.06", "0.07", "0.074"]
      "9.95":  ["9.925", "9.93", "9.94", "9.95", "9.96", "9.97", "9.974"]
      "10":    ["9.975", "9.98", "9.99", "10"]
    }
      for i in vals
        ui.typeIn $numberField, i
        equal $numberField.val(), rounded, "#{ i } gets rounded to #{ rounded }."
    return
  
  test "can use fractional steps with a min attribute", ->
    $numberField.attr "step", "0.05"
    $numberField.attr "min", "0.02"
    
    for rounded, vals of {
      "0.02":  ["-10", "-5.43", "0", "0.01", "0.02", "0.03", "0.04", "0.044"]
      "0.07":  ["0.045", "0.05", "0.06", "0.07", "0.08", "0.09", "0.094"]
      "0.12":  ["0.095", "0.1", "0.11", "0.12", "0.13", "0.14", "0.144"]
      "9.97":  ["9.945", "9.95", "9.96", "9.97", "9.98", "9.99", "9.994"]
      "10.02": ["9.995", "10", "10.01", "10.02"]
    }
      for i in vals
        ui.typeIn $numberField, i
        equal $numberField.val(), rounded, "#{ i } gets rounded to #{ rounded }."
    return

  test "increments the value on mousewheel up with an integer step", 10, ->
    $numberField.attr "step", "2"
    ui.typeIn $numberField, "-10"

    for i in [-8..10] by 2
      ui.mousewheelup($numberField)
      equal $numberField.val(), i.toString(), "Increments value to #{ i }."
    return
  
  test "increments the value on mousewheel up with a fractional step", 21, ->
    $numberField.attr "step", "0.001"
    ui.typeIn $numberField, "-0.01"
    equal $numberField.val(), "-0.01", "Value starts at -0.01."

    for i in ["-0.009", "-0.008", "-0.007", "-0.006", "-0.005", "-0.004", "-0.003", "-0.002", "-0.001", "0", "0.001", "0.002", "0.003", "0.004", "0.005", "0.006", "0.007", "0.008", "0.009", "0.01"]
      ui.mousewheelup($numberField)
      equal $numberField.val(), i, "Increments value to #{ i }."
    return
  
  test "decrements the value on mousewheel down with an integer step", 10, ->
    $numberField.attr "step", "2"
    ui.typeIn $numberField, "10"
    for i in [8..-10] by -2
      ui.mousewheeldown($numberField)
      equal $numberField.val(), i.toString(), "Decrements value to #{ i }."
    return
  
  test "decrements the value on mousewheel down with a fractional step", 21, ->
    $numberField.attr "step", "0.001"
    ui.typeIn $numberField, "0.01"
    equal $numberField.val(), "0.01", "Value starts at 0.01."
    for i in ["0.009", "0.008", "0.007", "0.006", "0.005", "0.004", "0.003", "0.002", "0.001", "0", "-0.001", "-0.002", "-0.003", "-0.004", "-0.005", "-0.006", "-0.007", "-0.008", "-0.009", "-0.01"]
      ui.mousewheeldown($numberField)
      equal $numberField.val(), i, "Decrements value to #{ i }."
    return
  
  module "upBtn"
  
  test "increments the value when clicked", 21, ->
    $numberField.attr "step", "0.001"
    ui.typeIn $numberField, "-0.01"
    equal $numberField.val(), "-0.01", "Value starts at -0.01."
    for i in ["-0.009", "-0.008", "-0.007", "-0.006", "-0.005", "-0.004", "-0.003", "-0.002", "-0.001", "0", "0.001", "0.002", "0.003", "0.004", "0.005", "0.006", "0.007", "0.008", "0.009", "0.01"]
      ui.click($upBtn)
      equal $numberField.val(), i, "Increments value to #{ i }."
    return
  
  module "downBtn"
  
  test "decrements the value when clicked", 21, ->
    $numberField.attr "step", "0.001"
    ui.typeIn $numberField, "0.01"
    equal $numberField.val(), "0.01", "Value starts at 0.01."
    for i in ["0.009", "0.008", "0.007", "0.006", "0.005", "0.004", "0.003", "0.002", "0.001", "0", "-0.001", "-0.002", "-0.003", "-0.004", "-0.005", "-0.006", "-0.007", "-0.008", "-0.009", "-0.01"]
      ui.click($downBtn)
      equal $numberField.val(), i, "Decrements value to #{ i }."
    return
  return
)(jQuery)
