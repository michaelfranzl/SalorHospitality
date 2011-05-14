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
  $('html, body').animate({scrollTop: $('#articles').offset().top - 40}, 500);
  display_articles(category_id);
  deselect_all_categories();
  highlight_border(element);
}

function display_quantities(art_id) {
  if ($('article_' + art_id + '_quantities').innerHTML == '') {
    $('article_' + art_id + '_quantities').innerHTML = quantitylist[art_id];
    $('html, body').animate({scrollTop: $('#article_' + art_id + '_quantities').offset().top - 40}, 500);
  } else {
    $('article_' + art_id + '_quantities').innerHTML = '';
  }
}

function hide_optionsselect(what) {
  // this should never be hidden on mobile
}

function hide_tableselect(what) {
  // this should never be hidden on mobile
}
