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

function category_onmousedown(category_id, element) {
  display_articles(category_id);
  deselect_all_categories();
  highlight_border(element);
  if ( mobile_special ) {
    y = $('#articles').position().top;
    window.scrollTo(0,y);
  } else {
    scroll_to('#articles', 7);
  }
}

function display_comment_popup_of_item(d) {
  var old_comment = items_json[d].o;
  var comment = prompt(i18n_enter_comment, old_comment);
  if ( comment == null ) { comment = old_comment };
  set_json(d,'o',comment);
	$('#comment_' + d).html(comment);
}

function display_price_popup_of_item(d) {
  var old_price = items_json[d].price;
  if (old_price == 0) { old_price = '' }
  var price = prompt(i18n_enter_price, old_price);
  if ( price == null || price == '' ) {
    price = old_price;
  }
  price = price.replace(',', '.');
  set_json(d,'price',price);
	calculate_sum();
	$('#price_for_item_' + d).slideUp();
}

function render_options(options, d, cat_id) {
/*
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
*/
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
    keep_fields_of_item(item_designator,'_optionslist');
    $('#optionsnames_' + item_designator).html('');
    itemoptions.html('');

  } else if (select_tag.value == -2 ) {
    // just exit, do nothing

  } else if (select_tag.value == -1 ) {
    // special option: do not print
    $('#item_' + item_designator + '_printed_count').val($('#item_' + item_designator + '_count').val());
    keep_fields_of_item(item_designator,'_printed_count');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else if (select_tag.value == -3 ) {
    // special option: takeaway
    $('#order_items_attributes_' + item_designator + '_usage').val(1);
    keep_fields_of_item(item_designator,'_usage');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_takeaway);

  } else {
    // options from database
    optionslist = $('#order_items_attributes_' + item_designator + '_optionslist').val();
    $('#order_items_attributes_' + item_designator + '_optionslist').val(optionslist + select_tag.value + ' ');
    keep_fields_of_item(item_designator,'_optionslist');
    var index = $('#optionsselect_select_' + original_designator).attr('selectedIndex');
    var text = $('#optionsselect_select_' + original_designator).attr('options')[index].text;
    $('#optionsnames_' + item_designator).append('<br>' + text);
    itemoptions.append('<input id="item_' + item_designator + '_option_' + select_tag.value + '" class="optionprice" type="hidden" value="' + optionsdetails[select_tag.value][0] + '">');
  }
  $('#optionsselect_select_' + item_designator).val(-2); //reset
  calculate_sum();
}
