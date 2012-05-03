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
  
  $('input#order_note').keyboard( {openOn: '' } );
  $('#order_note_display_keyboard').click(function(){
    $('input#order_note').getkeyboard().reveal();
  });
  
  var screenlock_counter = screenlock_timeout;
  window.setInterval(
    function() {
      if (screenlock_counter == 0) { $('#screenlock form').submit(); }
      screenlock_counter -= 1;
    }
  , 1001);
})

function category_onmousedown(category_id, element) {
  display_articles(category_id);
  deselect_all_categories();
  highlight_border(element);
}

function display_comment_popup_of_item(d) {
  var old_comment = items_json[d].comment;
  $('input#comment_for_item_' + d).val(old_comment);
  $('#comment_for_item_' + d).slideDown();
}

function add_comment_to_item(d) {
	var comment = $('input#comment_for_item_' + d).val();
  set_json(d,'comment',comment);
	$('#comment_' + d).html(comment);
	$('#comment_for_item_' + d).slideUp();
}

function display_price_popup_of_item(d) {
  var old_price = items_json[d].price;
  $('input#price_for_item_' + d).val(old_price);
  $('#price_for_item_' + d).slideDown();
}

function add_price_to_item(d) {
	price = $('input#price_for_item_' + d).val();
	$('#price_' + d).html(price);
	price = price.replace(',', '.');
  set_json(d,'price',price);
	calculate_sum();
	$('#price_for_item_' + d).slideUp();
}

function enable_keyboard_for_items(item_designator) {
  $('input#comment_for_item_' + item_designator).keyboard({openOn: '' });
  $('#comment_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#comment_for_item_' + item_designator).getkeyboard().reveal();
  });
  $('input#price_for_item_' + item_designator).keyboard({openOn: '', layout: 'num' });
  $('#price_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#price_for_item_' + item_designator).getkeyboard().reveal();
  });
}

function render_options(options, d, cat_id) {
  jQuery.each(options, function(key,value) {
    button = $(document.createElement('span'));
    button.html(value.n);
    button.addClass('option');
    (function() {
      var catid = cat_id;
      var object = value;
      button.on('click',function(){
        add_option_to_item_from_div(value, d, value.id, value.p, value.n, cat_id);
      });
    })();
    $('#options_div_' + d).append(button);
  });
}

function add_option_to_item_from_div(object, d, value, price, text, cat_id) {
  if (items_json[d].i == '' && items_json[d].count != 1 && value > 0) {
    var quantity_id = items_json[d].quantity_id;
    position = items_json[d].s;  
    clone_d = add_new_item(d, cat_id, true, d, position-1);
    decrement_item(d);
    $('#options_div_' + d).slideUp();
    d = clone_d;
  }

  option_uid += 1;
  if (value == 0) {
    // normal, delete all options
    set_json(d,'i',[]);
    $('#optionsnames_' + d).html('');

  } else if (value == -2 ) {
    $('#options_div_' + d).slideUp(); // just exit

  } else if (value == -1 ) {
    // special option: do not print
    set_json(d,'pc',items_json[d].count);
    $('#optionsnames_' + d).append('<br>' + i18n_no_printing);

  } else if (value == -3 ) {
    // special option: takeaway
    set_json(d,'u',1);
    $('#optionsnames_' + d).append('<br>' + i18n_takeaway);

  } else {
    items_json[d].i[option_uid] = object;
    create_submit_json_record(d);
    if ( ! submit_json.items[d].hasOwnProperty('optionslist')) {
      submit_json.items[d]['optionslist'] = [];
    }
    submit_json.items[d].optionslist.push(object.id);
    $('#optionsnames_' + d).append(text + '<br>');
  }

  calculate_sum();
}
