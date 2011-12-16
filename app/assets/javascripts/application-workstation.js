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

function toggle_admin_interface() {
  $.ajax({ type: 'POST', url:'/orders/toggle_admin_interface' });
}

function category_onmousedown(category_id, element) {
  display_articles(category_id);
  deselect_all_categories();
  $(element).css('border','2px solid white');
}

function display_quantities(art_id, article_div) {
  $('#quantities').html(quantitylist[art_id]);
  $('#quantities').css('padding-top', $(article_div).position().top/2);
}

function add_comment_to_item(item_designator) {
  var old_comment = $('#order_items_attributes_' + item_designator + '_comment').val();
  $('input#comment_for_item_' + item_designator).val(old_comment);
  $('#comment_for_item_' + item_designator).slideDown();
}

function add_price_to_item(item_designator) {
  var old_price = $('#order_items_attributes_' + item_designator + '_price').val();
  $('input#price_for_item_' + item_designator).val(old_price);
  $('#price_for_item_' + item_designator).slideDown();
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

$(document).ready(function() {
  // ":not([safari])" is desirable but not necessary selector
  $('input:checkbox:not([safari])').checkbox();
  $('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
  $('input:radio').checkbox();
  if ($('#flash').children().size() > 0) {
    $('#flash').fadeIn(1000);
    setTimeout(function(){ $('#flash').fadeOut(1000); }, 5000);
  }

})

