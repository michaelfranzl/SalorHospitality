function category_onmousedown(category_id) {
  display_articles(category_id); deselect_all_categories();
}

function quantities_onmousedown(element) {
  highlight_button(element);
}

function display_quantities(art_id) {
  $('quantities').innerHTML = quantitylist[art_id];
}
