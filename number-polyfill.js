$(function(){
  if (!Modernizr.inputtypes.number) {
    var getParams = function(elem) {
      var step = $(elem).attr('step');
      step = /^-?\d+(?:\.\d+)?$/.test(step) ? parseFloat(step) : undefined;
      var min = $(elem).attr('min');
      min = /^-?\d+(?:\.\d+)?$/.test(min) ? parseFloat(min) : undefined;
      var max = $(elem).attr('max');
      max = /^-?\d+(?:\.\d+)?$/.test(max) ? parseFloat(max) : undefined;

      var val = parseFloat($(elem).val()) || (min || 0);

      return {
	min: min,
	max: max,
	step: step,
	val: val
      };
    };

    var clipValues = function(value, min, max) {
      if (max !== undefined && value > max) {
	return max;
      } else if (min !== undefined && value < min) {
	return min;
      } else {
	return value;
      }
    };
    
    var extractNumDecimalDigits = function(input) {
      if (input !== undefined) {
        var num = 0;
        var raisedNum = input;
        while (raisedNum != Math.round(raisedNum)) {
          num += 1;
          raisedNum = input * Math.pow(10, num);
        }
        return num;
      } else {
        return 0;
      }
    }

    var matchStep = function(value, min, max, step) {
      var stepDecimalDigits = extractNumDecimalDigits(step);
      if (step === undefined) {
	return value;
      } else if (stepDecimalDigits == 0) {
	var mod = (value - (min || 0)) % step;
	if (mod == 0) {
	  return value;
	} else {
	  var stepDown = value - mod;
	  var stepUp = stepDown + step;
	  if ((stepUp > max) || ((value - stepDown) < (stepUp - value))) {
	    return stepDown;
	  } else {
	    return stepUp;
	  }
	}
      } else {
	var raiseTo = Math.pow(10, stepDecimalDigits);
	var raisedStep = step * raiseTo;
	var raisedMod = (value - (min || 0)) * raiseTo % raisedStep;
	if (raisedMod == 0) {
	  return value;
	} else {
	  var raisedValue = (value * raiseTo);
	  var raisedStepDown = raisedValue - raisedMod;
	  var raisedStepUp = raisedStepDown + raisedStep;
	  if (((raisedStepUp / raiseTo) > max) || ((raisedValue - raisedStepDown) < (raisedStepUp - raisedValue))) {
	    return (raisedStepDown / raiseTo);
	  } else {
	    return (raisedStepUp / raiseTo);
	  }
	}
      }
    };

    var increment = function(elem) {
      var params = getParams(elem);
      var raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
      var newVal = (Math.round(params['val'] * raiseTo) + Math.round((params['step'] || 1) * raiseTo)) / raiseTo;

      if (params['max'] !== undefined && newVal > params['max']) newVal = params['max'];
      newVal = matchStep(newVal, params['min'], params['max'], params['step']);

      $(elem).val(newVal);
    };
    
    var decrement = function(elem, amt) {
      var params = getParams(elem);
      var raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
      var newVal = (Math.round(params['val'] * raiseTo) - Math.round((params['step'] || 1) * raiseTo)) / raiseTo;

      if (params['min'] !== undefined && newVal < params['min']) newVal = params['min'];
      newVal = matchStep(newVal, params['min'], params['max'], params['step']);

      $(elem).val(newVal);
    };

    $('input[type="number"]').each(function(index) {
      var elem = this;
      var halfHeight = ($(elem).outerHeight() / 2) + 'px';
      var upBtn = document.createElement('div');
      $(upBtn).addClass('number-spin-btn');
      $(upBtn).addClass('number-spin-btn-up');
      $(upBtn).css('height', halfHeight);
      var downBtn = document.createElement('div');
      $(downBtn).addClass('number-spin-btn');
      $(downBtn).addClass('number-spin-btn-down');
      $(downBtn).css('height', halfHeight);
      var btnContainer = document.createElement('div');
      btnContainer.appendChild(upBtn);
      btnContainer.appendChild(downBtn);
      $(btnContainer).addClass('number-spin-btn-container');
      $(btnContainer).insertAfter(elem);

      $(elem).bind({
	DOMMouseScroll: function(event) {
	  if (event.detail < 0) {
	    increment(this);
	  } else {
	    decrement(this);
	  }
          event.preventDefault();
	},
	mousewheel: function(event) {
	  if (event.wheelDelta > 0) {
	    increment(this);
	  } else {
	    decrement(this);
	  }
          event.preventDefault();
	},
	keypress: function(event) {
	  if (event.keyCode == 38) { // up arrow
	    increment(this);
	  } else if (event.keyCode == 40) { // down arrow
	    decrement(this);
	  } else if (([8, 35, 36, 37, 39].indexOf(event.keyCode) == -1) &&
		     ([45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57].indexOf(event.which) == -1)) {
	    event.preventDefault();
	  }
	},
	change: function(event) {
          if (event.originalEvent !== undefined) {
	    var params = getParams(this);

	    newVal = clipValues(params['val'], params['min'], params['max']);
	    newVal = matchStep(newVal, params['min'], params['max'], params['step'], params['stepDecimal']);

	    $(this).val(newVal);
	  }
	}
      });
      $(upBtn).bind({
	mousedown: function(event) {
	  increment(elem);
	  
	  var timeoutFunc = function(elem, incFunc) {
	    incFunc(elem);

	    elem.timeoutID = window.setTimeout(timeoutFunc, 10, elem, incFunc);
	  };
	  
	  var releaseFunc = function(event) {
	    window.clearTimeout(elem.timeoutID);
	    $(document).unbind('mouseup', releaseFunc);
	    $(upBtn).unbind('mouseleave', releaseFunc);
	  };

	  $(document).bind('mouseup', releaseFunc);
	  $(upBtn).bind('mouseleave', releaseFunc);
	  
	  elem.timeoutID = window.setTimeout(timeoutFunc, 700, elem, increment);
	}
      });
      $(downBtn).bind({
	mousedown: function(event) {
	  decrement(elem);
	  
	  var timeoutFunc = function(elem, decFunc) {
	    decFunc(elem);

	    elem.timeoutID = window.setTimeout(timeoutFunc, 10, elem, decFunc);
	  };
	  
	  var releaseFunc = function(event) {
	    window.clearTimeout(elem.timeoutID);
	    $(document).unbind('mouseup', releaseFunc);
	    $(downBtn).unbind('mouseleave', releaseFunc);
	  };

	  $(document).bind('mouseup', releaseFunc);
	  $(downBtn).bind('mouseleave', releaseFunc);
	  
	  elem.timeoutID = window.setTimeout(timeoutFunc, 700, elem, decrement);
	}
      });
      $(this).css('text-align', 'right');
    });
  }
});
