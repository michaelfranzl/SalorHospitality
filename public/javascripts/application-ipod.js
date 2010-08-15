function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',75); display_articles(category_id); deselect_all_categories();
}

function articles_onmousedown(element) {
  Effect.ScrollTo('quantities',75); highlight_button(element); deselect_all_articles();
}

function quantities_onmousedown(element) {
  Effect.ScrollTo('items',75); highlight_button(element);
}
