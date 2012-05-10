var screenlock_counter = -1;

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

  screenlock_counter = screenlock_timeout;
  window.setInterval(function() {
    if (screenlock_counter == 0) { $('#screenlock form').submit(); }
    screenlock_counter -= 1;
    if(typeof(display_queue) != 'undefined') { display_queue(); }
  }, 1001);
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

function add_option_to_item_from_div(optionobject, d, value, price, text, cat_id) {
  if (items_json[d].c > 1 && value > 0) {
    var clone_d = add_new_item(items_json[d], cat_id, true, d);
    decrement_item(d);
    $('#options_div_' + d).slideUp();
    d = clone_d;
  }

  option_position = items_json[d].i.length + 1;
  if (value == 0) {
    // delete all options
    set_json(d,'i',[0]);
    set_json(d,'t',{});
    $('#optionsnames_' + d).html('');

  } else if (value == -1 ) {
    set_json(d,'pc',items_json[d].c);
    $('#optionsnames_' + d).append('<br>' + i18n_no_printing);

  } else if (value == -2 ) {
    set_json(d,'u',value);
    $('#optionsnames_' + d).append('<br>' + i18n_takeaway);

  } else if (value == -11 ) {
    set_json(d,'u',value);
    $('#optionsnames_' + d).append('1');

  } else if (value == -12 ) {
    set_json(d,'u',value);
    $('#optionsnames_' + d).append('2');

  } else if (value == -13 ) {
    set_json(d,'u',value);
    $('#optionsnames_' + d).append('3');

  } else {
    items_json[d].t[option_position] = optionobject;
    var list = items_json[d].i;
    list.push(optionobject.id);
    set_json(d,'i',list);
    $('#optionsnames_' + d).append(text + '<br>');
  }

  calculate_sum();
}
