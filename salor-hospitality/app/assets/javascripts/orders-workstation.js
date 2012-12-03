/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var screenlock_counter = -1;

// document ready code
$(function(){
  $('#admin').slideUp();

  $("#customer_search").keyup(function () {
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
      if (screenlock_counter == 0) { $('#screenlock form').submit(); }
      screenlock_counter -= 1;
    }, 1001);
  }
  
  $('#drag_and_drop_toggle_view_button').on('click', function() {
    var newstatus = !settings.mobile_drag_and_drop
    settings.mobile_drag_and_drop = newstatus;
    if (newstatus == true) {
      $('#areas').show();
      $('#mobile_last_invoices_button').hide();
      $('#drag_and_drop_toggle_view_button').html(i18n.workstation_view);
    } else {
      $('#areas').hide();
      $('#mobile_last_invoices_button').show();
      $('#drag_and_drop_toggle_view_button').html(i18n.mobile_view);
    }
    update_tables();
  })
})



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

function enable_keyboard_for_items(item_designator) {
  $('input#comment_for_item_' + item_designator).keyboard({
    openOn: '',
    visible: function(){
      $('.ui-keyboard-input').select();
    }
  });
  $('#comment_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#comment_for_item_' + item_designator).getkeyboard().reveal();
  });
  $('input#price_for_item_' + item_designator).keyboard({
    openOn: '',
    layout: 'num',
    visible: function(){
      $('.ui-keyboard-input').select();
    }
  });
  $('#price_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#price_for_item_' + item_designator).getkeyboard().reveal();
  });
}

function catch_keypress(d,type) {
  if (event.keyCode == 27) {
    // Escape
  } else if (event.keyCode == 13) {
    // Enter
    if (type == 'comment') {
      add_comment_to_item(d);
    } else if (type == 'price') {
      add_price_to_item(d);
    }
  }
}

function display_items_notifications() {
  $("#items_notifications_interactive").fadeIn();
  counter_update_item_lists = 1;
  audio_enabled = false; // skip one beep
}

function hide_items_notifications() {
  $("#items_notifications_interactive").fadeOut();
  counter_update_item_lists = timeout_update_item_lists;
}

function toggle_admin_interface() {
  $.ajax({
    type: 'POST',
    url:'/orders/toggle_admin_interface',
    dataType: 'json',
    success: function(result) {
      if (result) {
        $('#admin').slideDown('slow');
        if (! $('#orderform').is(':visible')) {
          $('#drag_and_drop_toggle_view_button').show();
        }
        $('#items_notifications_static').hide();
      } else {
        $('#admin').slideUp('slow');
        $('#drag_and_drop_toggle_view_button').hide();
        $('#items_notifications_static').show();
        settings.mobile_drag_and_drop = false;
        $('#areas').hide();
      }
      $('#drag_and_drop_toggle_view_button').html(i18n.mobile_view);
      settings.admin_interface = result;
      render_tables();
    }
  });
}