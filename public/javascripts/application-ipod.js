function category_onmousedown(category_id) {
  Effect.ScrollTo('articles',10);
  display_articles(category_id);
  deselect_all_categories();
}

function display_quantities(art_id) {
  if ($('article_' + art_id + '_quantities').innerHTML == '') {
    $('article_' + art_id + '_quantities').innerHTML = quantitylist[art_id];
    Effect.ScrollTo('article_' + art_id + '_quantities');
  } else {
    $('article_' + art_id + '_quantities').innerHTML = '';
  }
}

function hide_optionsselect(what) {
  // optionsselect should never be hidden on ipod
}
