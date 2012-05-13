/*
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
*/
var screenlock_counter = -1;

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

/*
  screenlock_counter = settings.screenlock_timeout;
  window.setInterval(function() {
    if (screenlock_counter == 0) { $('#screenlock form').submit(); }
    screenlock_counter -= 1;
    if(typeof(display_queue) != 'undefined') { display_queue(); }
  }, 1001);
*/
})

function display_comment_popup_of_item(d) {
  var old_comment = items_json[d].comment;
  $('input#comment_for_item_' + d).val(old_comment);
  $('#comment_for_item_' + d).slideDown();
  $('input#comment_for_item_' + d).focus();
}

function add_comment_to_item(d) {
	var comment = $('input#comment_for_item_' + d).val();
  set_json(d,'o',comment);
	$('#comment_' + d).html(comment);
	$('#comment_for_item_' + d).slideUp();
}

function display_price_popup_of_item(d) {
  var old_price = items_json[d].p;
  $('input#price_for_item_' + d).val(old_price);
  $('#price_for_item_' + d).slideDown();
}

function add_price_to_item(d) {
	price = $('input#price_for_item_' + d).val();
	$('#price_' + d).html(price);
	price = price.replace(',', '.');
  set_json(d,'p',price);
	calculate_sum();
	$('#price_for_item_' + d).slideUp();
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

function open_options_div(d) {
  if ( ! items_json[d].hasOwnProperty('id') || (items_json[d].c > items_json[d].sc)) {
    $('#options_div_'+d).slideDown();
  }
}

function catch_keypress(d) {
  if (event.keyCode == 27) {
    // Escape
  } else if (event.keyCode == 13) {
    // Enter
    add_comment_to_item(d);
    add_price_to_item(d);
  }
}

