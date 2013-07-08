/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function switch_to_invoice() {
  $('#invoices').show();
  $('#items_notifications_interactive').hide();
  $('#spliced_seasons').hide();
  //$('#items_notifications_static').hide();
  $('#orderform').hide();
  $('#tables').hide();
  $('#rooms').hide();
  $('#areas').hide();
  //$('#screenwait').hide();
  //$('#inputfields').html('');
  $('#itemstable').html('');
  $('#functions_header_invoice_form').show();
  $('#functions_header_order_form').hide();
  $('#functions_header_index').hide();
  $('#functions_footer').hide();
  $('#note_for_order').hide();
}

function switch_to_table() {
  scroll_to($('#container'),20);
  invoice_update = true;
  get_table_show_retry = true;
  send_queue_attempts = 0;
  $('#order_sum').html('0' + i18n.decimal_separator + '00');
  screenlock_counter = -1;
  advertising_counter = -1;
  counter_update_tables = -1;
  //$('#order_info').html(i18n.just_order);
  $('#note_for_order').hide();
  $('#order_note').val('');
  //$('#inputfields').html('');
  $('#itemstable').html('');
  $('#articles').html('');
  $('#quantities').html('');
  $('.target_table').val('');
  $('#spliced_seasons').hide();
  $('#items_notifications_interactive').hide();
  $('#items_notifications_static').hide();
  $('#functions_header_last_invoices').hide();
  $('#order_cancel_button').show();
  //---
  $('#orderform').show();
  $('#invoices').hide();
  $('#tables').hide();
  $('#areas').hide();
  $('#rooms').hide();
  $('.booking_form').remove();
  $('#functions_header_index').hide();
  $('#functions_header_invoice_form').hide();
  $('#functions_header_order_form').show();
  if (settings.mobile) { $('#functions_footer').show(); }
}

function switch_to_tables() {
  $('#orderform').hide();
  $('#invoices').hide();
  $('#items_notifications_interactive').hide();
  $('#items_notifications_static').show();
  $('#main').show();
  $('#tables').show();
  $('#admin').hide();
  $('#rooms').hide();
  $('#note_for_order').hide();
  $('#spliced_seasons').hide();
  if (settings.mobile) { $('#areas').show(); }
  $('#functions_header_index').show();
  $('#functions_header_order_form').hide();
  $('#functions_header_invoice_form').hide();
  $('#functions_footer').hide();
  $('#functions_header_last_invoices').hide();
  $('#customer_list').hide();
  $('.booking_form').hide();
  $('#tablesselect').hide();
  screenlock_counter = settings.screenlock_timeout;
  advertising_counter = settings.advertising_timeout;
  option_position = 0;
  item_position = 0;
  counter_update_tables = timeout_update_tables;
  send_queue_attempts = 100; // stop all reconnecting attempts
  update_tables();
  if (settings.mobile && typeof(model_id) != 'undefined') {
    scroll_to($('#table' + model_id), 20);
  } else {
    scroll_to($('#container'),20);
  }
}

function toggle_advertising(state) {
  if (state == true) {
    $('#advertising').css('z-index', 1000);
    $('#advertising').fadeIn(8000);
  } else {
    $('#advertising').hide();
    $('#advertising').css('z-index', -1000);
    advertising_counter = settings.advertising_timeout;
  }
}

function switch_to_digital_menucard() {
  $('#container').hide();
  $('#digital_menucard').show();
}

function switch_from_digital_menucard() {
  $('#container').show();
  $('#digital_menucard').hide();
}

