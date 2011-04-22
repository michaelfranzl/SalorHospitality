/*
BillGastro -- The innovative Point Of Sales Software for your Restaurant
Copyright (C) 2011  Michael Franzl <michael@billgastro.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

var tableupdates = -1;

function display_articles(cat_id) {
  $('articles').innerHTML = articleslist[cat_id];
  $('quantities').innerHTML = '&nbsp;';
}

function add_new_item_q(qu_id, button) {

  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;
  var category_id = itemdetails_q[qu_id][6];

  if (optionsselect[category_id]) {
    var options = optionsselect[category_id];
  } else {
    var options = ' ';
  }

  // search if quantity_id is already in the inputfields div
  var all_quantity_ids = $$("#inputfields .quantity_id");

  for(i=0; i<all_quantity_ids.length; i++) {
    if (qu_id == all_quantity_ids[i].value) {
      var matched_quantity = all_quantity_ids[i];
      matched_quantity.id.match(/^order_items_attributes_(.*)_quantity_id$/);
      var matched_designator = RegExp.$1;
      break;
    }
  };

  if (matched_designator &&
      $('order_items_attributes_' + matched_designator + '__destroy').value == 0 &&
      $('order_items_attributes_' + matched_designator + '_price').value == itemdetails_q[qu_id][3] )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSSELECT/g,options);

    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_q[qu_id][5]).replace(/PRICE/g,itemdetails_q[qu_id][3]).replace(/ARTICLEID/g,itemdetails_q[qu_id][0]).replace(/QUANTITYID/g,qu_id).replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'');

    $('itemstable').insert({ top: new_item_tablerow_modified });
    $('inputfields').insert({ top: new_item_inputfields_modified });

    if (itemdetails_q[qu_id][7] == 1 || itemdetails_q[qu_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }
  }
  calculate_sum();
}




function add_new_item_a(art_id, button, caption) {

  var timestamp = new Date().getTime();
  var sort = timestamp.toString().substr(-9,9);
  var desig = 'new_' + sort;
  var category_id = itemdetails_a[art_id][6];

  if (optionsselect[category_id]) {
    var options = optionsselect[category_id];
  } else {
    var options = ' ';
  }


  // search if article_id is already in the inputfields div
  var all_article_ids = $$("#inputfields .article_id");

  for(i=0; i<all_article_ids.length; i++) {
    if (art_id == all_article_ids[i].value) {
      var matched_article = all_article_ids[i];
      matched_article.id.match(/^order_items_attributes_(.*)_article_id$/);
      var matched_designator = RegExp.$1;
      break;
    }
  };

  if (matched_designator &&
      $('order_items_attributes_' + matched_designator + '__destroy').value == 0 &&
      $('order_items_attributes_' + matched_designator + '_price').value == itemdetails_a[art_id][3] )
  {
    increment_item(matched_designator);
  }
  else
  {
    new_item_tablerow_modified = new_item_tablerow.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSSELECT/g,options);
    new_item_inputfields_modified = new_item_inputfields.replace(/DESIGNATOR/g,desig).replace(/SORT/g,sort).replace(/LABEL/g,itemdetails_a[art_id][5]).replace(/PRICE/g,itemdetails_a[art_id][3]).replace(/ARTICLEID/g,itemdetails_a[art_id][0]).replace(/QUANTITYID/g,'').replace(/OPTIONSLIST/g,'').replace(/OPTIONSNAMES/g,'').replace(/PRICE/g,itemdetails_a[art_id][3]);
    $('itemstable').insert({ top: new_item_tablerow_modified });
    $('inputfields').insert({ top: new_item_inputfields_modified });

    if (itemdetails_a[art_id][7] == 1 || itemdetails_a[art_id][7] == 2) { add_comment_to_item(desig); add_price_to_item(desig); }
  }

  document.getElementById('quantities').innerHTML = '&nbsp;';
  calculate_sum();
}

function increment_item(desig) {
  $('tablerow_'+desig+'_count').innerHTML = $('order_items_attributes_' + desig + '_count').value++ + 1;
  calculate_sum();
}

function decrement_item(desig) {
  var i = parseInt($('order_items_attributes_' + desig + '_count').value);

  if (i < 2) {
    Effect.DropOut('item_' + desig );
    $('order_items_attributes_' + desig + '__destroy').value = 1;
  };

  if (i > 0) {
    $('tablerow_'+desig+'_count').innerHTML = $('order_items_attributes_' + desig + '_count').value-- - 1;
    calculate_sum();
  };
}



function deselect_all_categories() {
  var container = document.getElementById("categories");
  var cats = container.children;
  for(c in cats) {
    if (cats[c].style) {
      cats[c].style.borderColor = "#555555 #222222 #222222 #555555";
    }
  }
}


function deselect_all_articles() {
  var container = document.getElementById("articles");
  var arts = container.rows;
  for(count in arts) {
    if (arts[count].firstChild) {
      arts[count].firstChild.style.borderColor = "#555555 #222222 #222222 #555555";
    }
  }
}

function remove_item(desig) {
  Effect.DropOut('item_' + desig );
  //$('item_' + desig ).remove();
  $('order_items_attributes_' + desig + '__destroy').value = 1;
  $('order_items_attributes_' + desig + '_count').value = 0;
  calculate_sum();
}

function calculate_sum() {
  var prices = $$("#inputfields .price");
  var counts = $$("#inputfields .count");
  var sum = 0;
  for(i=0; i<prices.length; i++) {
    sum += parseFloat(prices[i].value) * parseFloat(counts[i].value);
  };
  $('order_sum').value = sum.toFixed(2).replace('.', ',');
  return sum;
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


function add_comment_to_item(item_designator) {
  var fallback = document.getElementById('order_items_attributes_' + item_designator + '_comment').value;
  var comment = prompt(enter_comment, fallback);
  if ( comment == null ) { comment = fallback };
  document.getElementById('order_items_attributes_' + item_designator + '_comment').value = comment;
  $('comment_' + item_designator).innerHTML = comment;
}


function add_price_to_item(item_designator) {
  var old_price = $('order_items_attributes_' + item_designator + '_price').value;
  if (old_price == 0) { old_price = '' }
  var price = prompt(enter_price, old_price);
  if ( price == null ) {
    price = old_price;
    if ( price == '') { price = 0 };
  }
  price = price.replace(',', '.');
  document.getElementById('order_items_attributes_' + item_designator + '_price').value = price;
  $('price_' + item_designator).innerHTML = price;
  calculate_sum();
}

function add_option_to_item(item_designator, select_tag)
{
  var tablerow = $('item_'+item_designator);
  var itemfields = $('fields_for_item_'+item_designator);

  if (select_tag.value == 0) {
    // normal, delete all options
    $('order_items_attributes_' + item_designator + '_optionslist').value = '';
    $('order_items_attributes_' + item_designator + '_printoptionslist').value = '';
    $('optionsnames_' + item_designator).innerHTML = '';

  } else if (select_tag.value == -2 ) {
    // exit, nothing

  } else if (select_tag.value == -1 ) {
    // special option: do not print
    $('order_items_attributes_' + item_designator + '_printed_count').value++;
    $('optionsnames_' + item_designator).insert('<br>fertig');

  } else {
    $('order_items_attributes_' + item_designator + '_printoptionslist').value += (select_tag.value+' ');
    var index = $('optionsselect_' + item_designator).selectedIndex;
    var text = $('optionsselect_' + item_designator).options[index].text;
    $('optionsnames_' + item_designator).insert('<br>'+text);
  }
  $('optionsselect_'+item_designator).value = -2; //reset
}


// VISUAL EFFECTS FUNCTINOS THAT MIGHT BE DIFFERENT ON mobile

function articles_onmousedown(element) {
  new Effect.Highlight(element);
  highlight_border(element);
}

function quantities_onmousedown(element) {
  new Effect.Highlight(element);
  highlight_border(element);
}

function highlight_border(element) {
   element.style.borderColor = "white";
}

function restore_border(element) {
   element.style.borderColor = "#555555 #222222 #222222 #555555";
}

function highlight_button(element) {
   new Effect.Highlight(element);
}

function restore_button(element) {
}

//ajax support functions

//this works also if offline. will be repeated in view of remote function.
function go_to_order_form_preprocessing(table_id) {
  Effect.ScrollTo("header");

  $('order_sum').value = '0';

  $('order_id').value = 'add_offline_items_to_order';
  $('order_info').innerHTML = 'Schnellbestellung';
  $('order_action').value = '';
  $('order_table_id').value = table_id;

  $('inputfields').innerHTML = '';
  $('itemstable').innerHTML = '';
  $('articles').innerHTML = '';
  $('quantities').innerHTML = '';

  $('orderform').show();
  $('invoices').hide();
  $('tables').hide();
  $('rooms').hide();
  $('functions_header_index').hide();
  $('functions_header_order_form').show();
  $('functions_footer').show();

  new Ajax.Request('/tables/'+table_id, {method:'get'});
}

function go_to_tables_offline() {
  $('orderform').hide();
  $('invoices').hide();
  $('tables').show();
  $('rooms').show();
  $('functions_header_index').show();
  $('functions_header_order_form').hide();
  $('functions_header_invoice_form').hide();
  $('functions_footer').hide();
  Effect.ScrollTo("header");
  $('save_and_go_to_tables').style.backgroundImage = "url('/images/button_mobile_tables.png')";
  $('save_and_go_to_tables').style.border = "none";
}

new PeriodicalExecuter(
  function() {
    //$('flash_notice').innerHTML = '                              ' + tableupdates;
    if (tableupdates > 0) {
      new Ajax.Request('/tables', {asynchronous:true, evalScripts:true, method:'get'});
    }
    else if (tableupdates == 0) {
      alert('Der Server antwortet nicht mehr. Der Server ist entweder überlastet oder die Funkverbindung ist abgerissen.');
    }
    tableupdates -= 1;
  }
, 20)


