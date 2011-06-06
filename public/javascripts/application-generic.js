/*
BillGastro -- The innovative Point Of Sales Software for your Restaurant
Copyright (C) 2011  Michael Franzl <michael@billgastro.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

jQuery.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
    }
})


var tableupdates = -1;
var automatic_printing = 0;

function display_articles(cat_id) {
  $('#articles').html(articleslist[cat_id]);
  $('#quantities').html('&nbsp;');
}

function add_new_item_q(qu_id, button) {

  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;
  var category_id = itemdetails_q[qu_id][6];

  if (optionsselect[category_id]) {
    var options_select = optionsselect[category_id];
  } else {
    var options_select = ' ';
  }

  if (optionsdiv[category_id]) {
    var options_div = optionsdiv[category_id];
  } else {
    var options_div = ' ';
  }

  // search if quantity_id is already in the inputfields div
  var all_quantity_ids = $('#inputfields .quantity_id');

  for(i=0; i<all_quantity_ids.length; i++) {
    if (qu_id == all_quantity_ids[i].value) {
      var matched_quantity = all_quantity_ids[i];
      matched_quantity.id.match(/^order_items_attributes_(.*)_quantity_id$/);
      var matched_designator = RegExp.$1;
      break;
    }
  };

  if (matched_designator &&
      $('#order_items_attributes_' + matched_designator + '_price').val() == itemdetails_q[qu_id][3] )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSSELECT/g,options_select).replace(/OPTIONSDIV/g,options_div).replace(/DESIGNATOR/g,desig);

    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'');

    $('#itemstable').prepend(new_item_tablerow_modified);
    $('#inputfields').prepend(new_item_inputfields_modified);

    if (itemdetails_q[qu_id][7] == 1 || itemdetails_q[qu_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }
  }
  calculate_sum();
}




function add_new_item_a(art_id, button, caption) {

  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;
  var category_id = itemdetails_a[art_id][6];

  if (optionsselect[category_id]) {
    var options_select = optionsselect[category_id];
  } else {
    var options_select = ' ';
  }

  if (optionsdiv[category_id]) {
    var options_div = optionsdiv[category_id];
  } else {
    var options_div = ' ';
  }


  // search if article_id is already in the inputfields div
  var all_article_ids = $('#inputfields .article_id');

  for(i=0; i<all_article_ids.length; i++) {
    if (art_id == all_article_ids[i].value) {
      var matched_article = all_article_ids[i];
      matched_article.id.match(/^order_items_attributes_(.*)_article_id$/);
      var matched_designator = RegExp.$1;
      break;
    }
  };

  if (matched_designator &&
      $('#order_items_attributes_' + matched_designator + '_price').val() == itemdetails_a[art_id][3] )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSSELECT/g,options_select).replace(/OPTIONSDIV/g,options_div).replace(/DESIGNATOR/g,desig);
    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'').replace(/PRICE/g,itemdetails_a[art_id][3]);
    $('#itemstable').prepend(new_item_tablerow_modified);
    $('#inputfields').prepend(new_item_inputfields_modified);

    if (itemdetails_a[art_id][7] == 1 || itemdetails_a[art_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }
  }

  $('#quantities').html('&nbsp;');
  calculate_sum();
}

function increment_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  i++;
  $('#order_items_attributes_' + desig + '_count').val(i);
  $('#tablerow_' + desig + '_count').html(i);
  calculate_sum();
}

function decrement_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  if (i > 1) {
    i--;
    $('#order_items_attributes_' + desig + '_count').val(i);
    $('#tablerow_' + desig + '_count').html(i);
  } else if (permission_immediate_storno) {
    $('#order_items_attributes_' + desig + '__destroy').val(1);
    $('#item_' + desig).fadeOut("slow");
  };
  calculate_sum();
}

function deselect_all_categories() {
  var container = $('#categories');
  var cats = container.children();
  for(c in cats) {
    if (cats[c].style) {
      cats[c].style.borderColor = '#555555 #222222 #222222 #555555';
    }
  }
}

function calculate_sum() {
  var prices = $('#inputfields .price');
  var counts = $('#inputfields .count');
  var sum = 0;
  for(i=0; i<prices.length; i++) {
    sum += parseFloat(prices[i].value) * parseFloat(counts[i].value);
  };
  $('#order_sum').val(sum.toFixed(2).replace('.', ','));
  return sum;
}


function mark_item_for_storno(list_id, order_id, item_id) {
  if ( $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value == 1 ) {
    list_id.style.backgroundColor = 'transparent';
    $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value = 0;
  } else {
    list_id.style.backgroundColor = '#FCC';
    $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value = 1;
  }
}

function add_option_to_item_from_select(item_designator, select_tag)
{
  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);

  if (select_tag.value == 0) {
    // normal, delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    $('#order_items_attributes_' + item_designator + '_printoptionslist').val('');
    $('#optionsnames_' + item_designator).html('');

  } else if (select_tag.value == -2 ) {
    // exit, nothing

  } else if (select_tag.value == -1 ) {
    // special option: do not print
    printedcount = parseInt($('#order_items_attributes_' + item_designator + '_printed_count').val());
    $('#order_items_attributes_' + item_designator + '_printed_count').val(printedcount + 1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else {
    printoptionslist = $('#order_items_attributes_' + item_designator + '_printoptionslist').val();
    $('#order_items_attributes_' + item_designator + '_printoptionslist').val(printoptionslist + select_tag.value + ' ');
    var index = $('#optionsselect_select_' + item_designator).attr('selectedIndex');
    var text = $('#optionsselect_select_' + item_designator).attr('options')[index].text;
    $('#optionsnames_' + item_designator).append('<br>' + text);
  }
  $('#optionsselect_select_' + item_designator).val(-2); //reset
  $('#optionsselect_select_' + item_designator).hide();
}

function add_option_to_item_from_div(item_designator, value, text)
{
  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);

  if (value == 0) {
    // normal, delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    $('#order_items_attributes_' + item_designator + '_printoptionslist').val('');
    $('#optionsnames_' + item_designator).html('');

  } else if (value == -2 ) {
    // exit, nothing

  } else if (value == -1 ) {
    // special option: do not print
    printedcount = parseInt($('#order_items_attributes_' + item_designator + '_printed_count').val());
    $('#order_items_attributes_' + item_designator + '_printed_count').val(printedcount + 1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else {
    printoptionslist = $('#order_items_attributes_' + item_designator + '_printoptionslist').val();
    $('#order_items_attributes_' + item_designator + '_printoptionslist').val(printoptionslist + value + ' ');
    $('#optionsnames_' + item_designator).append('<br>' + text);
  }
  $('#optionsselect_div_' + item_designator).slideUp();
}


function articles_onmousedown(element) {
  highlight_border(element);
}

function quantities_onmousedown(element) {
  highlight_border(element);
}

function articles_onmouseup(element) {
  $(element).effect("highlight", {}, 300);
}

function quantities_onmouseup(element) {
  $(element).effect("highlight", {}, 300);
}

function highlight_border(element) {
  $(element).css('borderColor', 'white');
}

function restore_border(element) {
  $(element).css({ borderColor: '#555555 #222222 #222222 #555555' });
}

function highlight_button(element) {
  $(element).effect("highlight", {}, 300);
}

function restore_button(element) {
  $(element).css({ backgroundColor: '#3A474D' });
}

//ajax support functions

//this works also if offline. will be repeated in view of remote function.
function go_to_order_form_preprocessing(table_id) {
  scroll_to($('#container'),20);
  $('#order_sum').value = '0';

  $('#order_id').val('add_offline_items_to_order');
  $('#order_info').html(i18n_just_order);
  $('#order_action').val('');
  $('#order_table_id').val(table_id);

  $('#inputfields').html('');
  $('#itemstable').html('');
  $('#articles').html('');
  $('#quantities').html('');

  $('#orderform').show();
  $('#invoices').hide();
  $('#tables').hide();
  $('#rooms').hide();
  $('#functions_header_index').hide();
  $('#functions_header_invoice_form').hide();
  $('#functions_header_order_form').show();
  $('#functions_footer').show();
  $.ajax({ type: 'GET', url: '/tables/' + table_id });
}

function go_to_tables_offline() {
  scroll_to($('#container'),20);
  $('#orderform').hide();
  $('#invoices').hide();
  $('#tables').show();
  $('#rooms').show();
  $('#functions_header_index').show();
  $('#functions_header_order_form').hide();
  $('#functions_header_invoice_form').hide();
  $('#functions_footer').hide();
  $('#save_and_go_to_tables').css('backgroundImage', 'url("/images/button_mobile_tables.png")');
  $('#save_and_go_to_tables').css('border','none');
}

window.setInterval(
  function() {
    //$('#flash_notice').html('                              ' + tableupdates);
    if ( automatic_printing == true ) {
      window.location.href = '/items.bill';
    }
    if (tableupdates > 0) {
      $.ajax({ url: '/tables' });
    }
    else if (tableupdates == 0) {
      alert(i18n_server_no_response);
    }
    tableupdates -= 1;
  }
, 12000);

function scroll_to(element, speed) {
  target_y = $(window).scrollTop();
  current_y = $(element).offset().top;
  do_scroll(current_y - target_y, speed);
}

function scroll_for(distance, speed) {
  do_scroll(distance, speed);
}

function do_scroll(diff, speed) {
  window.scrollBy(0,diff/speed);
  newdiff = (speed-1)*diff/speed;
  scrollAnimation = setTimeout(function(){ do_scroll(newdiff, speed) }, 20);
  if(Math.abs(diff) < 1) { clearTimeout(scrollAnimation); }
}
