function toggle_admin_interface() {
  new Ajax.Request('/orders/toggle_admin_interface');
}

function category_onmousedown(category_id) {
  display_articles(category_id); deselect_all_categories();
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
