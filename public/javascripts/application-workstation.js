function category_onmousedown(category_id) {
  display_articles(category_id); deselect_all_categories();
}

function articles_onmousedown(element) {
  highlight_button(element); deselect_all_articles();
}

function quantities_onmousedown(element) {
  highlight_button(element);
}
