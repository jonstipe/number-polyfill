/*
HTML5 Number polyfill | Jonathan Stipe | https://github.com/jonstipe/number-polyfill
*/

(function($) {
  var i;
  i = document.createElement("input");
  i.setAttribute("type", "number");
  if (i.type === "text") {
    $.fn.inputNumber = function() {
      var clipValues, decrement, domMouseScrollHandler, extractNumDecimalDigits, getParams, increment, matchStep, mouseWheelHandler;
      getParams = function(elem) {
        var $elem, max, min, step, val;
        $elem = $(elem);
        step = $elem.attr('step');
        min = $elem.attr('min');
        max = $elem.attr('max');
        val = parseFloat($elem.val());
        step = /^-?\d+(?:\.\d+)?$/.test(step) ? parseFloat(step) : null;
        min = /^-?\d+(?:\.\d+)?$/.test(min) ? parseFloat(min) : null;
        max = /^-?\d+(?:\.\d+)?$/.test(max) ? parseFloat(max) : null;
        if (isNaN(val)) {
          val = min || 0;
        }
        return {
          min: min,
          max: max,
          step: step,
          val: val
        };
      };
      clipValues = function(value, min, max) {
        if ((max != null) && value > max) {
          return max;
        } else if ((min != null) && value < min) {
          return min;
        } else {
          return value;
        }
      };
      extractNumDecimalDigits = function(input) {
        var num, raisedNum;
        if (input != null) {
          num = 0;
          raisedNum = input;
          while (raisedNum !== Math.round(raisedNum)) {
            num += 1;
            raisedNum = input * Math.pow(10, num);
          }
          return num;
        } else {
          return 0;
        }
      };
      matchStep = function(value, min, max, step) {
        var mod, raiseTo, raisedMod, raisedStep, raisedStepDown, raisedStepUp, raisedValue, stepDecimalDigits, stepDown, stepUp;
        stepDecimalDigits = extractNumDecimalDigits(step);
        if (step == null) {
          return value;
        } else if (stepDecimalDigits === 0) {
          mod = (value - (min || 0)) % step;
          if (mod === 0) {
            return value;
          } else {
            stepDown = value - mod;
            stepUp = stepDown + step;
            if ((stepUp > max) || ((value - stepDown) < (stepUp - value))) {
              return stepDown;
            } else {
              return stepUp;
            }
          }
        } else {
          raiseTo = Math.pow(10, stepDecimalDigits);
          raisedStep = step * raiseTo;
          raisedMod = (value - (min || 0)) * raiseTo % raisedStep;
          if (raisedMod === 0) {
            return value;
          } else {
            raisedValue = value * raiseTo;
            raisedStepDown = raisedValue - raisedMod;
            raisedStepUp = raisedStepDown + raisedStep;
            if (((raisedStepUp / raiseTo) > max) || ((raisedValue - raisedStepDown) < (raisedStepUp - raisedValue))) {
              return raisedStepDown / raiseTo;
            } else {
              return raisedStepUp / raiseTo;
            }
          }
        }
      };
      increment = function(elem) {
        var newVal, params, raiseTo;
        if (!$(elem).is(":disabled")) {
          params = getParams(elem);
          raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
          newVal = (Math.round(params['val'] * raiseTo) + Math.round((params['step'] || 1) * raiseTo)) / raiseTo;
          if ((params['max'] != null) && newVal > params['max']) {
            newVal = params['max'];
          }
          newVal = matchStep(newVal, params['min'], params['max'], params['step']);
          $(elem).val(newVal).change();
        }
        return null;
      };
      decrement = function(elem) {
        var newVal, params, raiseTo;
        if (!$(elem).is(":disabled")) {
          params = getParams(elem);
          raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
          newVal = (Math.round(params['val'] * raiseTo) - Math.round((params['step'] || 1) * raiseTo)) / raiseTo;
          if ((params['min'] != null) && newVal < params['min']) {
            newVal = params['min'];
          }
          newVal = matchStep(newVal, params['min'], params['max'], params['step']);
          $(elem).val(newVal).change();
        }
        return null;
      };
      domMouseScrollHandler = function(e) {
        e.preventDefault();
        if (e.originalEvent.detail < 0) {
          increment(this);
        } else {
          decrement(this);
        }
        return null;
      };
      mouseWheelHandler = function(e) {
        e.preventDefault();
        if (e.originalEvent.wheelDelta > 0) {
          increment(this);
        } else {
          decrement(this);
        }
        return null;
      };
      $(this).filter('input[type="number"]').each(function() {
        var $downBtn, $elem, $upBtn, attrMutationCallback, attrObserver, btnContainer, downBtn, elem, halfHeight, upBtn;
        elem = this;
        $elem = $(elem);
        halfHeight = ($elem.outerHeight() / 2) + 'px';
        upBtn = document.createElement('div');
        downBtn = document.createElement('div');
        $upBtn = $(upBtn);
        $downBtn = $(downBtn);
        btnContainer = document.createElement('div');
        $upBtn.addClass('number-spin-btn number-spin-btn-up').css('height', halfHeight);
        $downBtn.addClass('number-spin-btn number-spin-btn-down').css('height', halfHeight);
        btnContainer.appendChild(upBtn);
        btnContainer.appendChild(downBtn);
        $(btnContainer).addClass('number-spin-btn-container').insertAfter(elem);
        $elem.on({
          focus: function(e) {
            $elem.on({
              DOMMouseScroll: domMouseScrollHandler,
              mousewheel: mouseWheelHandler
            });
            return null;
          },
          blur: function(e) {
            $elem.off({
              DOMMouseScroll: domMouseScrollHandler,
              mousewheel: mouseWheelHandler
            });
            return null;
          },
          keypress: function(e) {
            var _ref, _ref1;
            if (e.keyCode === 38) {
              increment(this);
            } else if (e.keyCode === 40) {
              decrement(this);
            } else if (((_ref = e.keyCode) !== 8 && _ref !== 9 && _ref !== 35 && _ref !== 36 && _ref !== 37 && _ref !== 39 && _ref !== 46) && ((_ref1 = e.which) !== 45 && _ref1 !== 48 && _ref1 !== 49 && _ref1 !== 50 && _ref1 !== 51 && _ref1 !== 52 && _ref1 !== 53 && _ref1 !== 54 && _ref1 !== 55 && _ref1 !== 56 && _ref1 !== 57)) {
              e.preventDefault();
            }
            return null;
          },
          change: function(e) {
            var newVal, params;
            if (e.originalEvent != null) {
              params = getParams(this);
              newVal = clipValues(params['val'], params['min'], params['max']);
              newVal = matchStep(newVal, params['min'], params['max'], params['step'], params['stepDecimal']);
              $(this).val(newVal);
            }
            return null;
          }
        });
        $upBtn.on("mousedown", function(e) {
          var releaseFunc, timeoutFunc;
          increment(elem);
          timeoutFunc = function(elem, incFunc) {
            incFunc(elem);
            $elem.data("timeoutID", window.setTimeout(timeoutFunc, 10, elem, incFunc));
            return null;
          };
          releaseFunc = function(e) {
            window.clearTimeout($elem.data("timeoutID"));
            $(document).off('mouseup', releaseFunc);
            $upBtn.off('mouseleave', releaseFunc);
            return null;
          };
          $(document).on('mouseup', releaseFunc);
          $upBtn.on('mouseleave', releaseFunc);
          $elem.data("timeoutID", window.setTimeout(timeoutFunc, 700, elem, increment));
          return null;
        });
        $downBtn.on("mousedown", function(e) {
          var releaseFunc, timeoutFunc;
          decrement(elem);
          timeoutFunc = function(elem, decFunc) {
            decFunc(elem);
            $elem.data("timeoutID", window.setTimeout(timeoutFunc, 10, elem, decFunc));
            return null;
          };
          releaseFunc = function(e) {
            window.clearTimeout($elem.data("timeoutID"));
            $(document).off('mouseup', releaseFunc);
            $downBtn.off('mouseleave', releaseFunc);
            return null;
          };
          $(document).on('mouseup', releaseFunc);
          $downBtn.on('mouseleave', releaseFunc);
          $elem.data("timeoutID", window.setTimeout(timeoutFunc, 700, elem, decrement));
          return null;
        });
        $elem.css("textAlign", 'right');
        if ($elem.css("opacity") !== "1") {
          $(btnContainer).css("opacity", $elem.css("opacity"));
        }
        if ($elem.css("visibility") !== "visible") {
          $(btnContainer).css("visibility", $elem.css("visibility"));
        }
        if (elem.style.display !== "") {
          $(btnContainer).css("display", $elem.css("display"));
        }
        if ((typeof WebKitMutationObserver !== "undefined" && WebKitMutationObserver !== null) || (typeof MutationObserver !== "undefined" && MutationObserver !== null)) {
          attrMutationCallback = function(mutations, observer) {
            var mutation, _i, _len;
            for (_i = 0, _len = mutations.length; _i < _len; _i++) {
              mutation = mutations[_i];
              if (mutation.type === "attributes") {
                if (mutation.attributeName === "class") {
                  $(btnContainer).removeClass(mutation.oldValue).addClass(elem.className);
                } else if (mutation.attributeName === "style") {
                  $(btnContainer).css({
                    "opacity": elem.style.opacity,
                    "visibility": elem.style.visibility,
                    "display": elem.style.display
                  });
                }
              }
            }
            return null;
          };
          attrObserver = (typeof WebKitMutationObserver !== "undefined" && WebKitMutationObserver !== null) ? new WebKitMutationObserver(attrMutationCallback) : ((typeof MutationObserver !== "undefined" && MutationObserver !== null) ? new MutationObserver(attrMutationCallback) : null);
          attrObserver.observe(elem, {
            attributes: true,
            attributeOldValue: true,
            attributeFilter: ["class", "style"]
          });
        } else if (typeof MutationEvent !== "undefined" && MutationEvent !== null) {
          $elem.on("DOMAttrModified", function(evt) {
            if (evt.originalEvent.attrName === "class") {
              $(btnContainer).removeClass(evt.originalEvent.prevValue).addClass(evt.originalEvent.newValue);
            } else if (evt.originalEvent.attrName === "style") {
              $(btnContainer).css({
                "display": elem.style.display,
                "visibility": elem.style.visibility,
                "opacity": elem.style.opacity
              });
            }
            return null;
          });
        }
        return null;
      });
      return $(this);
    };
    $(function() {
      $('input[type="number"]').inputNumber();
      return null;
    });
    null;
  } else {
    $.fn.inputNumber = function() {
      return $(this);
    };
    null;
  }
  return null;
})(jQuery);
