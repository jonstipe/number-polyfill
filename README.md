# Number polyfill

This is a polyfill for implementing the HTML5 `<input type="number">` element in browsers that do not currently support it.

## Usage

Using it is easy — simply include the `number-polyfill.js` file in the HEAD of the HTML page.  
You can then use `<input type="number">` elements normally.

If the script detects that the browser doesn't support `<input type="number">`, it will search for these elements and attach some Javascript to them to make them function as number-only input fields, and add increment/decrement buttons.

A default CSS file is provided. You may edit this file to style the buttons to make them look the way you want.

## Manual usage

The script can also be called manually as a jQuery plugin for elements dynamically generated through script. Simply call the `.inputNumber()` method on any jQuery object containing one or more `<input type="number">` elements.

## Dependencies

This script requires [jQuery](http://jquery.com/).

## Demo

http://jonstipe.github.com/number-polyfill/demo.html

## Test suite

http://jonstipe.github.com/number-polyfill/unittest.html

## See also

[Compatibility chart for input number elements](http://caniuse.com/input-number)

## License (MIT)
Copyright (c) 2011 Jonathan Stipe

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

