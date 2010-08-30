function display_articles(cat_id) {
  $('articlestable').innerHTML = articleslist[cat_id];
  $('quantitiestable').innerHTML = '&nbsp;';
}



function add_new_item_q(qu_id) {
  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;

  new_item_tablerow_modified = new_item_tablerow.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id);

  new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id);

  $('itemstable').insert({ top: new_item_tablerow_modified });
  $('inputfields').insert({ top: new_item_inputfields_modified });
  var sum = calculate_sum();
  $('order_sum').value = sum.toFixed(2).replace('.', ',');
}

function add_new_item_a(art_id) {
  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;

  new_item_tablerow_modified = new_item_tablerow.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICEg/,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'');

  new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'');

  $('itemstable').insert({ top: new_item_tablerow_modified });
  $('inputfields').insert({ top: new_item_inputfields_modified });
  document.getElementById('quantitiestable').innerHTML = '&nbsp;';

  var sum = calculate_sum();
  $('order_sum').value = sum.toFixed(2).replace('.', ',');
}

function increment_item(desig) {
  $('count_' + desig).innerHTML = $('order_items_attributes_' + desig + '_count').value++ + 1;
  var sum = calculate_sum();
  $('order_sum').value = sum.toFixed(2).replace('.', ',');
}

function decrement_item(desig) {
  var i = parseInt($('order_items_attributes_' + desig + '_count').value);

  if (i < 2) {
    Effect.DropOut('item_' + desig );
    $('order_items_attributes_' + desig + '__destroy').value = 1;
  };

  if (i > 0) {
    $('count_' + desig).innerHTML = $('order_items_attributes_' + desig + '_count').value-- - 1;
    var sum = calculate_sum();
    $('order_sum').value = sum.toFixed(2).replace('.', ',');
  };
}

function highlight_button(element) {
   element.style.borderColor = "white";
}

function restore_button(element) {
   element.style.borderColor = "#555555 #222222 #222222 #555555";
}

function deselect_all_categories() {
  var container = document.getElementById("categories");
  var cats = container.children;
  for(c in cats) {
    cats[c].style.borderColor = "#555555 #222222 #222222 #555555";
  }
}


function deselect_all_articles() {
  var container = document.getElementById("articlestable");
  var arts = container.rows;
  for(count in arts) {
    arts[count].firstChild.style.borderColor = "#555555 #222222 #222222 #555555";
  }
}

function remove_item(desig) {
  Effect.DropOut('item_' + desig );
  //$('item_' + desig ).remove();
  $('order_items_attributes_' + desig + '__destroy').value = 1;
  $('order_items_attributes_' + desig + '_count').value = 0;
  var sum = calculate_sum();
  $('order_sum').value = sum.toFixed(2).replace('.', ',');
}

function calculate_sum() {
  var prices = $$("#inputfields .price");
  var counts = $$("#inputfields .count");
  var sum = 0;
  for(i=0; i<prices.length; i++) {
    sum += parseFloat(prices[i].value) * parseFloat(counts[i].value);
  };
  return sum;
}


function mark_item_for_partial(list_id, order_id, item_id) {
  if ( $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value == 1 ) {
    list_id.style.backgroundColor = 'transparent';
    $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value = 0;
  } else {
    list_id.style.backgroundColor = '#CCC';
    $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value = 1;
  }
}

function mark_item_for_storno(list_id, order_id, item_id) {
  if ( $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value == 1 ) {
    list_id.style.backgroundColor = 'transparent';
    $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value = 0;
  } else {
    list_id.style.backgroundColor = '#FCC';
    $('order_items_attributes_'+order_id+'_'+item_id+'_storno_status').value = 1;
  }
}


// VISUAL EFFECTS FUNCTINOS THAT MIGHT BE DIFFERENT ON IPOD

function category_onmouseup(element) {
  highlight_button(element);
}

function articles_onmousedown(element) {
  highlight_button(element); deselect_all_articles();
}

function articles_onmouseup(element) {
  highlight_button(element);
}

function quantities_onmouseup(element) {
  restore_button(element);
}


