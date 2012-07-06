(function($){

	$(function () {
		var i = document.createElement("input");
		i.setAttribute("type", "number");
		if (i.type == "text") {
			var getParams = function (elem) {
					var step = $(elem).attr('step'),
						min = $(elem).attr('min'),
						max = $(elem).attr('max'),
						val = parseFloat($(elem).val());
					step = /^-?\d+(?:\.\d+)?$/.test(step) ? parseFloat(step) : undefined;					
					min = /^-?\d+(?:\.\d+)?$/.test(min) ? parseFloat(min) : undefined;
					max = /^-?\d+(?:\.\d+)?$/.test(max) ? parseFloat(max) : undefined;
					val = isNaN(val) ? min || 0 : val;

					return {
						min: min,
						max: max,
						step: step,
						val: val
					};
				};

			var clipValues = function (value, min, max) {
					if (max !== undefined && value > max) return max;
					else if (min !== undefined && value < min) return min;
					else return value;
				};

			var extractNumDecimalDigits = function (input) {
					if (input !== undefined) {
						var num = 0;
						var raisedNum = input;
						while (raisedNum != Math.round(raisedNum)) {
							num += 1;
							raisedNum = input * Math.pow(10, num);
						}
						return num;
					}
					else
						return 0;
				}

			var matchStep = function (value, min, max, step) {
					var stepDecimalDigits = extractNumDecimalDigits(step);
					if (step === undefined) return value;
					else if (stepDecimalDigits == 0) {
						var mod = (value - (min || 0)) % step;
						if (mod == 0) return value;
						else {
							var stepDown = value - mod;
							var stepUp = stepDown + step;
							if ((stepUp > max) || ((value - stepDown) < (stepUp - value))) return stepDown;
							else return stepUp;
						}
					} else {
						var raiseTo = Math.pow(10, stepDecimalDigits);
						var raisedStep = step * raiseTo;
						var raisedMod = (value - (min || 0)) * raiseTo % raisedStep;
						if (raisedMod == 0) return value;
						else {
							var raisedValue = (value * raiseTo);
							var raisedStepDown = raisedValue - raisedMod;
							var raisedStepUp = raisedStepDown + raisedStep;
							if (((raisedStepUp / raiseTo) > max) || ((raisedValue - raisedStepDown) < (raisedStepUp - raisedValue))) return (raisedStepDown / raiseTo);
							else return (raisedStepUp / raiseTo);
						}
					}
				};

			var increment = function (elem) {
					var params = getParams(elem);
					var raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
					var newVal = (Math.round(params['val'] * raiseTo) + Math.round((params['step'] || 1) * raiseTo)) / raiseTo;

					if (params['max'] !== undefined && newVal > params['max']) newVal = params['max'];
					newVal = matchStep(newVal, params['min'], params['max'], params['step']);

					$(elem).val(newVal).change();
				};

			var decrement = function (elem) {
					var params = getParams(elem);
					var raiseTo = Math.pow(10, Math.max(extractNumDecimalDigits(params['val']), extractNumDecimalDigits(params['step'])));
					var newVal = (Math.round(params['val'] * raiseTo) - Math.round((params['step'] || 1) * raiseTo)) / raiseTo;

					if (params['min'] !== undefined && newVal < params['min']) newVal = params['min'];
					newVal = matchStep(newVal, params['min'], params['max'], params['step']);

					$(elem).val(newVal).change();
				};

			$('input[type="number"]').each(function (index) {
				var elem = this;
				var halfHeight = ($(elem).outerHeight() / 2) + 'px';
				var upBtn = document.createElement('div');
				$(upBtn)
					.addClass('number-spin-btn number-spin-btn-up')
					.css('height', halfHeight);
				var downBtn = document.createElement('div');
				$(downBtn)
					.addClass('number-spin-btn number-spin-btn-down')
					.css('height', halfHeight);
				var btnContainer = document.createElement('div');
				btnContainer.appendChild(upBtn);
				btnContainer.appendChild(downBtn);
				$(btnContainer).addClass('number-spin-btn-container').insertAfter(elem);

				$(elem).bind({
					DOMMouseScroll: function (e) {
						e.preventDefault();
						if (e.originalEvent.detail < 0) increment(this);
						else decrement(this);
					},
					mousewheel: function (e) {
						e.preventDefault();
						if (e.wheelDelta > 0) increment(this);
						else decrement(this);
					},
					keypress: function (e) {
						if (e.keyCode == 38) // up arrow
							increment(this);
						else if (e.keyCode == 40) // down arrow
							decrement(this);
						else if (([8, 9, 35, 36, 37, 39].indexOf(e.keyCode) == -1) && ([45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57].indexOf(e.which) == -1))
							e.preventDefault();
					},
					change: function (e) {
						if (e.originalEvent !== undefined) {
							var params = getParams(this);

							newVal = clipValues(params['val'], params['min'], params['max']);
							newVal = matchStep(newVal, params['min'], params['max'], params['step'], params['stepDecimal']);

							$(this).val(newVal);
						}
					}
				});
				$(upBtn).bind({
					mousedown: function (e) {
						increment(elem);

						var timeoutFunc = function (elem, incFunc) {
								incFunc(elem);

								elem.timeoutID = window.setTimeout(timeoutFunc, 10, elem, incFunc);
							};

						var releaseFunc = function (e) {
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
					mousedown: function (e) {
						decrement(elem);

						var timeoutFunc = function (elem, decFunc) {
								decFunc(elem);
								elem.timeoutID = window.setTimeout(timeoutFunc, 10, elem, decFunc);
							};

						var releaseFunc = function (e) {
								window.clearTimeout(elem.timeoutID);
								$(document).unbind('mouseup', releaseFunc);
								$(downBtn).unbind('mouseleave', releaseFunc);
							};

						$(document).bind('mouseup', releaseFunc);
						$(downBtn).bind('mouseleave', releaseFunc);

						elem.timeoutID = window.setTimeout(timeoutFunc, 700, elem, decrement);
					}
				});
				$(this).css({ textAlign: 'right' });
			});
		}
	});

})(jQuery);