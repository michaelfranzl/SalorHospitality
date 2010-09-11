function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',10); display_articles(category_id); deselect_all_categories();
}

function display_quantities(art_id) {
  //document.getElementById('article_' + art_id + '_quantitylist').innerHTML = quantitylist[art_id];
  $('article_' + art_id).insert({ after: quantitylist[art_id] });
}

function quantities_onmousedown(element) {
  //Effect.ScrollTo('items',75); highlight_button(element);
  highlight_button(element);
  deselect_all_articles();
}
