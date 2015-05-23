/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function render_items() {
  // we will read all items attributes from the variable items_json, rendered by the server.
  jQuery.each(items_json, function(k,object) {
    var catid = object.ci;
    var label = compose_label(object)
    var optionnames = compose_optionnames(object);
    var scribeimage = scribe_image(object);
    tablerow = resources.templates.item.replace(/DESIGNATOR/g, object.d).replace(/COUNT/g, object.c).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, object.o).replace(/PRICE/g, object.p).replace(/LABEL/g, label).replace(/OPTIONSNAMES/g, optionnames).replace(/SCRIBE/g, scribeimage).replace(/CATID/g, catid).replace(/CURRENCY/g, i18n.currency_unit);
    $('#itemstable').append(tablerow);
    if (object.changed == true) {
      $('td#tablerow_' + object.d + '_count').addClass('updated');
    }
    if (object.p == 0) {
      $('#tablerow_' + object.d + '_label').addClass('zero_price');
    }
    $('#options_select_' + object.d).attr('disabled',true); // option selection is only allowed when count > start count, see increment
    if (settings.workstation) { enable_keyboard_for_items(object.d); }
    render_options(resources.c[catid].o, object.d);
  });
  calculate_sum();
}

function add_item_by_sku(sku) {
  var found_id = null;
  var found_model = null;

  $.each(resources.a, function(k, obj) {
    if (obj.sku == sku) {
      found_id = obj.ai;
      return true
    }
  });
  
  if (found_id) {
    add_new_item(found_id, "article");
    return
  }
  
  $.each(resources.q, function(k, obj) {
    if (obj.sku == sku) {
      found_id = obj.qi;
      return true
    }
  });
  
  if (found_id) {
    add_new_item(found_id, "quantity");
    return
  }
  
  
}


// object {hash} contains the attributes of the item that should be created.
// anchor_d {string} is the item designator before which the newly generated item will be inserted.
// add_new {boolean} causes always a new item to be created. no incrementation is done.
function add_new_item(id, model, add_new, anchor_d) {
  var object = {};
  if (model == 'article') {
    object = resources.a[id];
  } else if (model == 'quantity' ) {
    object = resources.q[id];
  }
  var d = object.d;
  var catid = object.ci;
  if (items_json.hasOwnProperty(d) &&
      !add_new &&
      items_json[d].p == object.p &&
      items_json[d].o == '' &&
      typeof(items_json[d].x) == 'undefined' &&
      $.isEmptyObject(items_json[d].t)
     ) {
    // an item with identical paramters is already in the list, and add_new is false, so just increment
    increment_item(d);
  } else {
    // an item with identical paramters is not yet in the list, or add_new is true, so create a new item
    d = create_json_record('order', object);
    var label = compose_label(object);
    var new_item = $(resources.templates.item.replace(/DESIGNATOR/g, d).replace(/COUNT/g, 1).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, '').replace(/PRICE/g, object.p).replace(/LABEL/g, label).replace(/OPTIONSNAMES/g, '').replace(/SCRIBE/g, '').replace(/CATID/g, catid).replace(/CURRENCY/g, i18n.currency_unit));
    if (anchor_d) {
      $(new_item).insertBefore($('#item_'+anchor_d));
    } else {
      $('#itemstable').prepend(new_item);
    }
    $('#tablerow_' + d + '_count').addClass('updated');
    var option_ids = resources.c[catid].o;
    render_options(option_ids, d);
    if (settings.workstation) { enable_keyboard_for_items(d); }
  }
  
  if ($('#digital_menucard:visible')) {
  }
  calculate_sum();
  return d;
}

function display_configuration_of_item(d) {
  if ($('#item_configuration_' + d).is(':visible')) {
    $('#item_configuration_' + d).remove();
  } else {
    row = $(document.createElement('tr'));
    row.attr('id','item_configuration_'+d);
    cell = $(document.createElement('td'));
    cell.attr('colspan',4);
    cell.addClass('item_configuration',4);

    comment_button =  $(document.createElement('span'));
    comment_button.addClass('item_comment');
    comment_button.on('click', function(){ display_comment_popup_of_item(d); });
    cell.append(comment_button);

    price_button =  $(document.createElement('span'));
    price_button.addClass('item_price');
    price_button.on('click', function(){ display_price_popup_of_item(d); });
    cell.append(price_button);

    if (item_changeable(d)) {
      if (permissions.item_scribe) {
        scribe_button =  $(document.createElement('span'));
        scribe_button.addClass('item_scribe');
        scribe_button.on('click', function() {
          $('#item_configuration_' + d).hide();
          d = clone_item(d);
          init_scribe(d);
        });
        cell.append(scribe_button);
      }
    }

    row.html(cell);
    row.addClass('item');
    row.insertAfter('#item_' + d);
  }
}

function compose_label(object) {
  var label = null;
  if (typeof object.qi == 'undefined') {
    // this is an article object
    label = object.n;
  } else {
    // this is an quantity object
    var articleobj = resources.a[object.ai];
    label = object.pre + ' ' + articleobj.n + ' ' + object.post;
  }
  return label;
}

function clone_item(d) {
  var object = items_json[d];
  var id = null;
  var model = null;
  if (object.c > 1 && permissions.add_option_to_sent_item == false) {
    if (typeof object.qi == 'undefined') {
      //this is an article object
      id = object.ai;
      model = 'article';
    } else {
      //this is an quantity object
      id = object.qi;
      model = 'quantity';
    }
    decrement_item(d);
    var d = add_new_item(id, model, true, d);
  }
  return d;
}

function item_changeable(d) {
  var start_count = items_json[d].sc;
  var count = items_json[d].c;
  return ( (typeof(start_count) == 'undefined') || count > start_count )
}

function increment_item(d) {
  $('#item_configuration_' + d).remove();
  var count = items_json[d].c + 1;
  var start_count = items_json[d].sc;
  var object = items_json[d];
  set_json('order', object.d,'c',count)
  $('#tablerow_' + d + '_count').html(count);
  $('#tablerow_' + d + '_count').addClass('updated');
  if ( count == start_count ) { $('#tablerow_' + d + '_count').removeClass('updated'); }
  if (settings.mobile) { permit_select_open(d, count, start_count); }
  calculate_sum();
}

function decrement_item(d) {
  var i = items_json[d].c;
  var start_count = items_json[d].sc;
  if ( i > 1 && ( permissions.decrement_items || i > start_count || ( ! items_json[d].hasOwnProperty('id') ) ) ) {
    i--;
    set_json('order', d, 'c', i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
    if ( i == start_count ) { $('#tablerow_' + d + '_count').removeClass('updated'); }
  } else if ( i == 1 && ( permissions.decrement_items || ( ! items_json[d].hasOwnProperty('id') ))) {
    i--;
    set_json('order', d, 'c', i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
    if (permissions.delete_items || start_count == undefined) {
      set_json('order', d, 'x', true);
      $('#item_' + d).fadeOut('slow');
    }
  }
  if (settings.mobile) { permit_select_open(d, i, start_count); }
  calculate_sum();
}