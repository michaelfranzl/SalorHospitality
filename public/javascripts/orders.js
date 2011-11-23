function customer_list_entry(customer) {
  var entry = $('<div class="entry" customer_id="' + customer['id'] + '" id="customer_entry_' + customer['id'] + '"></div>');
  entry.mousedown(function () {
    var id = '#customer_name_' + $(this).attr('customer_id');
    var field = $('<input type="hidden" name="order[customer_set][][id]" value="' + $(this).attr('customer_id') + '"/>');
    $("#order_form_ajax").append(field);
    $('#order_info').append("<span class='order-customer'>"+$(id).html()+"</span>");
  });
  entry.append("<span class='option' id='customer_name_" + customer['id'] + "'>" + customer['first_name'] + " " + customer['last_name'] + "</span>");
  return entry;
}

function customer_list_update() {
  $.getJSON('/customers?format=json&keywords=' + $('#customer_search').val() , function (data) {
    $('#customer_list_target').html('');
    for (i in data) {
      $('#customer_list_target').append(customer_list_entry(data[i]['customer']));
    }
  });
}

function display_articles(cat_id) {
  $('#articles').html(articleslist[cat_id]);
  $('#quantities').html('&nbsp;');
}

function add_new_item_q(qu_id, add_new, position, sort) {

  var timestamp = new Date().getTime();
  if ( sort == null ) { sort = timestamp.toString().substr(-9,9); }
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
      !add_new &&
      $('#order_items_attributes_' + matched_designator + '_price').val() == itemdetails_q[qu_id][3] &&
      $('#order_items_attributes_' + matched_designator + '_comment').val() == '' &&
      $('#order_items_attributes_' + matched_designator + '_usage').val() == 0 &&
      $('#order_items_attributes_' + matched_designator + '__destroy').val() != 1 &&
      $('#order_items_attributes_' + matched_designator + '_optionslist').val() == ''
     )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSSELECT/g,options_select).replace(/OPTIONSDIV/g,options_div).replace(/DESIGNATOR/g,desig);

    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'');

    if (position) {
      $(new_item_tablerow_modified).insertBefore(position);
    } else {
      $('#itemstable').prepend(new_item_tablerow_modified);
    }
    $('#inputfields').prepend(new_item_inputfields_modified);

    if (itemdetails_q[qu_id][7] == 1 || itemdetails_q[qu_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }

    $('#tablerow_' + desig + '_count').addClass('updated');
  }
  calculate_sum();
  return desig;
}




function add_new_item_a(art_id, add_new, position, sort) {

  var timestamp = new Date().getTime();
  if ( sort == null ) { sort = timestamp.toString().substr(-9,9); }
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
      !add_new &&
      $('#order_items_attributes_' + matched_designator + '_price').val() == itemdetails_a[art_id][3] &&
      $('#order_items_attributes_' + matched_designator + '_comment').val() == '' &&
      $('#order_items_attributes_' + matched_designator + '_usage').val() == 0 &&
      $('#order_items_attributes_' + matched_designator + '__destroy').val() != 1 &&
      $('#order_items_attributes_' + matched_designator + '_optionslist').val() == ''
     )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSSELECT/g,options_select).replace(/OPTIONSDIV/g,options_div).replace(/DESIGNATOR/g,desig);
    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'').replace(/PRICE/g,itemdetails_a[art_id][3]);
    
    if (position) {
      $(new_item_tablerow_modified).insertBefore(position);
    } else {
      $('#itemstable').prepend(new_item_tablerow_modified);
    }
    $('#inputfields').prepend(new_item_inputfields_modified);

    if (itemdetails_a[art_id][7] == 1 || itemdetails_a[art_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }

    $('#tablerow_' + desig + '_count').addClass('updated');
  }

  $('#quantities').html('&nbsp;');
  calculate_sum();
  return desig;
}

function increment_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  i++;
  $('#order_items_attributes_' + desig + '_count').val(i);
  $('#tablerow_' + desig + '_count').html(i);
  $('#tablerow_' + desig + '_count').addClass('updated');
  calculate_sum();
}

function decrement_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  var start_count = parseInt($('#item_' + desig + '_start_count').val());
  if ( i > 1 && ( permission_immediate_storno || i > start_count ) ) {
    i--;
    $('#order_items_attributes_' + desig + '_count').val(i);
    $('#tablerow_' + desig + '_count').html(i);
    $('#tablerow_' + desig + '_count').addClass('updated');
  } else if ( i == 1 && ( permission_immediate_storno || (desig.search(/new_.+/) != -1 ))) {
    i--;
    $('#order_items_attributes_' + desig + '_count').val(i);
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
  var items = $('#inputfields > div');
  var sum = 0;
  var itemcount;
  var itemprice;
  var options;
  for(i=0; i<items.length; i++) {
    itemcount = parseFloat($(items[i]).children('.count')[0].value);
    itemprice = parseFloat($(items[i]).children('.price')[0].value);
    sum += itemcount * itemprice;
    options = $(items[i]).children('div').children('.optionprice');
    for(j=0; j<options.length; j++) {
      optionprice = parseFloat(options[j].value);
      sum += optionprice * itemcount;
    }
  }
  $('#order_sum').val(sum.toFixed(2).replace('.', i18n_decimal_separator));
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
  original_designator = item_designator;

  if ($('#order_items_attributes_' + item_designator + '_optionslist').val() == '' && $('#order_items_attributes_' + item_designator + '_count').val() != 1 && select_tag.value > 0) {

    var quantity_id = $('#order_items_attributes_' + item_designator + '_quantity_id').val();
    var sort = parseInt($('#order_items_attributes_' + item_designator + '_sort').val());
  
    if ( quantity_id != '') {
      cloned_item_designator = add_new_item_q(quantity_id, true, $('#item_' + item_designator), sort - 1);
    } else {
      var article_id = $('#order_items_attributes_' + item_designator + '_article_id').val();
      cloned_item_designator = add_new_item_a(article_id, true, $('#item_' + item_designator), sort - 1);
    }
    decrement_item(item_designator);
    item_designator = cloned_item_designator;
  }

  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);
  var itemoptions = $('#options_for_item_' + item_designator);

  if (select_tag.value == 0) {
    // delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    $('#optionsnames_' + item_designator).html('');
    itemoptions.html('');

  } else if (select_tag.value == -2 ) {
    // just exit, do nothing

  } else if (select_tag.value == -1 ) {
    // special option: do not print
    $('#item_' + item_designator + '_prepared').val(1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else if (select_tag.value == -3 ) {
    // special option: takeaway
    $('#order_items_attributes_' + item_designator + '_usage').val(1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_takeaway);

  } else {
    // options from database
    optionslist = $('#order_items_attributes_' + item_designator + '_optionslist').val();
    $('#order_items_attributes_' + item_designator + '_optionslist').val(optionslist + select_tag.value + ' ');
    var index = $('#optionsselect_select_' + original_designator).attr('selectedIndex');
    var text = $('#optionsselect_select_' + original_designator).attr('options')[index].text;
    $('#optionsnames_' + item_designator).append('<br>' + text);
    itemoptions.append('<input id="item_' + item_designator + '_option_' + select_tag.value + '" class="optionprice" type="hidden" value="' + optionsdetails[select_tag.value][0] + '">');
  }
  $('#optionsselect_select_' + item_designator).val(-2); //reset
  calculate_sum();
}

function add_option_to_item_from_div(button, item_designator, value, price, text)
{

  if ($('#order_items_attributes_' + item_designator + '_optionslist').val() == '' && $('#order_items_attributes_' + item_designator + '_count').val() != 1 && value > 0) {

    var quantity_id = $('#order_items_attributes_' + item_designator + '_quantity_id').val();
    var sort = parseInt($('#order_items_attributes_' + item_designator + '_sort').val());
  
    if ( quantity_id != '') {
      cloned_item_designator = add_new_item_q(quantity_id, true, $('#item_' + item_designator), sort - 1);
    } else {
      var article_id = $('#order_items_attributes_' + item_designator + '_article_id').val();
      cloned_item_designator = add_new_item_a(article_id, true, $('#item_' + item_designator), sort - 1);
    }
    decrement_item(item_designator);
    $('#optionsselect_div_' + item_designator).slideUp();
    item_designator = cloned_item_designator;
  }

  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);
  var itemoptions = $('#options_for_item_' + item_designator);

  if (value == 0) {
    // normal, delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    $('#optionsnames_' + item_designator).html('');
    itemoptions.html('');

  } else if (value == -2 ) {
    $('#optionsselect_div_' + item_designator).slideUp(); // just exit

  } else if (value == -1 ) {
    // special option: do not print
    $('#item_' + item_designator + '_prepared').val(1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else if (value == -3 ) {
    // special option: takeaway
    $('#order_items_attributes_' + item_designator + '_usage').val(1);
    $('#optionsnames_' + item_designator).append('<br>' + i18n_takeaway);
  } else {
    optionslist = $('#order_items_attributes_' + item_designator + '_optionslist').val();
    $('#order_items_attributes_' + item_designator + '_optionslist').val(optionslist + value + ' ');
    $('#optionsnames_' + item_designator).append('<br>' + text);
    itemoptions.append('<input id="item_' + item_designator + '_option_' + value + '" class="optionprice" type="hidden" value="' + price + '">');
  }

  calculate_sum();
  $(button).effect("highlight", {}, 1000);
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
  $('#order_note').val('');
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
  screenlock_counter = -1;
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
  screenlock_counter = screenlock_timeout;
}

function move_order_to_table(id) {
  if ( id != "" ) {
    $(".tablesselect").slideUp();
    $("#order_action").val("move_order_to_table");
    $("#target_table").val(id);
    $("#order_form_ajax").submit();
  }
}

function change_item_status(id,status) {
  $.ajax({
    type: 'POST',
    url: '/items/change_status?id=' + id + '&status=' + status
  });
}

$(function(){
  $('#admin').hide();
  
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
  
  var screenlock_counter = screenlock_timeout;
  window.setInterval(
    function() {
      if (screenlock_counter == 0) { $('#screenlock form').submit(); }
      screenlock_counter -= 1;
    }
  , 1001);
  
  window.setInterval(
    function(){
      $.ajax({
        type: 'GET',
        url: '/items/list?scope=preparation'
      });
      $.ajax({
        type: 'GET',
        url: '/items/list?scope=delivery'
      });
    }
  , 20000);
  
  // display initial items notifications
  $.ajax({
    type: 'GET',
    url: '/items/list?scope=preparation'
  });
  $.ajax({
    type: 'GET',
    url: '/items/list?scope=delivery'
  });
})
