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

function display_comment_popup_of_item(item_designator) {
  var old_comment = $('#order_items_attributes_' + item_designator + '_comment').val();
  $('input#comment_for_item_' + item_designator).val(old_comment);
  $('#comment_for_item_' + item_designator).slideDown();
}

function add_comment_to_item(item_designator) {
	var comment = $('input#comment_for_item' + item_designator).val();
	$('#order_items_attributes_' + item_designator + '_comment').val(comment);
	keep_fields_of_item(item_designator,'_comment');
	$('#comment_' + item_designator).html(comment);
	$('#comment_for_item_' + item_designator).slideUp();
}

function display_price_popup_of_item(item_designator) {
  var old_price = $('#order_items_attributes_' + item_designator + '_price').val();
  $('input#price_for_item_' + item_designator).val(old_price);
  $('#price_for_item_' + item_designator).slideDown();
}

function add_price_to_item(item_designator) {
	price = $('input#price_for_item_' + item_designator).val();
	$('#price_' + item_designator).html(price);
	price = price.replace(',', '.');
	$('#order_items_attributes_' + item_designator + '_price').val(price);
	keep_fields_of_item(item_designator,'_price');
	calculate_sum();
	$('#price_for_item_' + item_designator).slideUp();
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
