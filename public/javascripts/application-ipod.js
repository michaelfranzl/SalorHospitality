function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',10); display_articles(category_id); deselect_all_categories();
}

function display_quantities(art_id) {
  $('article_' + art_id + '_quantities').innerHTML = quantitylist[art_id];
}
