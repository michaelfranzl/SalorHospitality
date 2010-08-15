function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',75); display_articles(category_id); deselect_all_categories();
}

function articles_onmousedown(element) {
  highlight_button(element); deselect_all_articles();
}

function display_quantities(art_id) {
  $('article_' + art_id).insert({ bottom: '<table>' + quantitylist[art_id] + '</table>' });
}

function quantities_onmousedown(element) {
  Effect.ScrollTo('items',75); highlight_button(element);
}
