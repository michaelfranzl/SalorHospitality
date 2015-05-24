/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


function display_comment_popup_of_item(d) {
  $('#item_configuration_' + d).hide();
  if ( item_changeable(d) ) {
    var old_comment = items_json[d].o;
    var comment = prompt(i18n.enter_comment, old_comment);
    if ( comment == null ) { comment = old_comment };
    add_comment_to_item(d,comment);
  } else {
    alert('+1');
  }
}

function display_price_popup_of_item(d) {
  $('#item_configuration_' + d).hide();
  var old_price = items_json[d].p;
  if (old_price == 0) { old_price = '' }
  var price = prompt(i18n.enter_price, old_price);
  if ( price == null || price == '' ) {
    price = old_price;
  } else {
    price = price.replace(',', '.');
  }
  add_price_to_item(d,price);
}

function add_comment_to_item(d,comment) {
  d = clone_item(d);
	$('#comment_' + d).html(comment);
  set_json('order', d,'o',comment);
  $('#tablerow_' + d + '_label').addClass('updated');
  $('#item_configuration_' + d).hide();
}

function add_price_to_item(d,price) {
  d = clone_item(d);
  set_json('order', d,'p',price);
	$('#price_' + d).html(price);
	calculate_sum();
  $('#tablerow_' + d + '_label').addClass('updated');
  $('#item_configuration_' + d).hide();
}
