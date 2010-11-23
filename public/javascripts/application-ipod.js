function category_onmousedown(category_id) {
  Effect.ScrollTo('articles', { offset:-40});
  display_articles(category_id);
  deselect_all_categories();
}

function display_quantities(art_id) {
  if ($('article_' + art_id + '_quantities').innerHTML == '') {
    $('article_' + art_id + '_quantities').innerHTML = quantitylist[art_id];
    Effect.ScrollTo('article_' + art_id + '_quantities', { offset:-50 });
  } else {
    $('article_' + art_id + '_quantities').innerHTML = '';
  }
}

function hide_optionsselect(what) {
  // this should never be hidden on ipod
}

function hide_tableselect(what) {
  // this should never be hidden on ipod
}
