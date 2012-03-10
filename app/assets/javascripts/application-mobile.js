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

function display_quantities(art_id, article_div) {
  if ($('#article_' + art_id + '_quantities').html() == '') {
    $('#article_' + art_id + '_quantities').html(quantitylist[art_id]);
    //scroll_to('#article_' + art_id + '_quantities', 15);
  } else {
    $('#article_' + art_id + '_quantities').html('');
  }
}

function hide_optionsselect(what) {
  // this should never be hidden on mobile
}

function hide_tableselect(what) {
  // this should never be hidden on mobile
}

function add_comment_to_item(item_designator) {
  var fallback = $('#order_items_attributes_' + item_designator + '_comment').val();
  var comment = prompt(i18n_enter_comment, fallback);
  if ( comment == null ) { comment = fallback };
  $('#order_items_attributes_' + item_designator + '_comment').val(comment);
  $('#order_items_attributes_' + item_designator + '_comment').attr('updated',1);
  $('#comment_' + item_designator).html(comment);
}

function add_price_to_item(item_designator) {
  var old_price = $('#order_items_attributes_' + item_designator + '_price').val();
  if (old_price == 0) { old_price = '' }
  var price = prompt(i18n_enter_price, old_price);
  if ( price == null || price == '' ) {
    price = old_price;
  }
  price = price.replace(',', '.');
  $('#order_items_attributes_' + item_designator + '_price').val(price);
  $('#order_items_attributes_' + item_designator + '_price').attr('updated',1);
  $('#price_' + item_designator).html(price);
  calculate_sum();
}
