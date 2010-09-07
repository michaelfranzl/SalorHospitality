function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',75); display_articles(category_id); deselect_all_categories();
}

function display_quantities(art_id) {
  document.getElementById('article_' + art_id + '_quantitylist').innerHTML = '<table>' + quantitylist[art_id] + '</table>';
}

function quantities_onmousedown(element) {
  //Effect.ScrollTo('items',75); highlight_button(element);
}
