/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var screenlock_counter = -1;
var advertising_counter = -1;

$(function(){
  $('#customer_search').keyup(function () {
    if ($(this).val().length > 2) {
      customer_list_update();
    }
  });
  
  $('#customer_search').keyboard( {openOn: '', accepted: function(){ customer_list_update(); } } );
  $('#customer_search_display_keyboard').click(function(){
    $('#customer_search').val('');
    $('#customer_search').getkeyboard().reveal();
  });
  
  $('input#order_note').keyboard( {openOn: '' } );
  $('#order_note_display_keyboard').click(function(){
    $('input#order_note').getkeyboard().reveal();
  });

  screenlock_counter = settings.screenlock_timeout;
  if (typeof(screenlock_interval) == 'undefined') {
    screenlock_interval = window.setInterval(function() {
      if (screenlock_counter == 0) { logout(); }
      screenlock_counter -= 1;
    }, 1001);
  }
  
  advertising_counter = settings.advertising_timeout;
  if (typeof(advertising_interval) == 'undefined') {
    advertising_interval = window.setInterval(function() {
      if (advertising_counter == 0) {
        toggle_advertising(true);
      }
      advertising_counter -= 1;
    }, 1002);
  }
  
});



function display_comment_popup_of_item(d) {
  $('#item_configuration_' + d).hide();
  var old_comment = items_json[d].o;
  $('input#comment_for_item_' + d).val(old_comment);
  $('#comment_for_item_' + d).slideDown();
  $('#item_configuration_' + d).hide();
  $('input#comment_for_item_' + d).select();
}

function display_price_popup_of_item(d) {
  $('#item_configuration_' + d).hide();
  var old_price = items_json[d].p;
  $('input#price_for_item_' + d).val(old_price);
  $('#price_for_item_' + d).slideDown();
  $('#item_configuration_' + d).hide();
  $('input#price_for_item_' + d).select();
}

function add_comment_to_item(d) {
  var comment = $('input#comment_for_item_' + d).val();
  $('#comment_for_item_' + d).slideUp();
  d = clone_item(d);
  set_json('order', d,'o',comment);
  $('#comment_' + d).html(comment);
  $('#tablerow_' + d + '_label').addClass('updated');
}

function add_price_to_item(d) {
  price = $('input#price_for_item_' + d).val();
  $('#price_' + d).html(price);
  price = price.replace(',', '.');
  set_json('order', d, 'p', price);
  calculate_sum();
  $('#price_for_item_' + d).slideUp();
  $('#tablerow_' + d + '_label').addClass('updated');
}

