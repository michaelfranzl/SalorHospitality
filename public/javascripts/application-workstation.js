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

function category_onmousedown(category_id) {
  display_articles(category_id); deselect_all_categories();
  highlight_border(element);
}

function display_quantities(art_id) {
  $('quantities').innerHTML = quantitylist[art_id];
}

function hide_optionsselect(what) {
  what.hide();
}

function hide_tableselect(what) {
  what.hide();
}
