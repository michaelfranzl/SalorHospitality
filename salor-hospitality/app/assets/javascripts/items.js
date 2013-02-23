/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function render_items() {
  jQuery.each(items_json, function(k,object) {
    catid = object.ci;
    tablerow = resources.templates.item.replace(/DESIGNATOR/g, object.d).replace(/COUNT/g, object.c).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, object.o).replace(/PRICE/g, object.p).replace(/LABEL/g, compose_label(object)).replace(/OPTIONSNAMES/g, compose_optionnames(object)).replace(/SCRIBE/g, scribe_image(object)).replace(/CATID/g, catid).replace(/CURRENCY/g, i18n.currency_unit);
    $('#itemstable').append(tablerow);
    if (object.changed == true) {
      $('td#tablerow_' + object.d + '_count').addClass('updated');
    }
    if (object.p == 0) {
      $('#tablerow_' + object.d + '_label').addClass('zero_price');
    }
    $('#options_select_' + object.d).attr('disabled',true); // option selection is only allowed when count > start count, see increment
    if (settings.workstation) { enable_keyboard_for_items(object.d); }
    render_options(resources.c[catid].o, object.d, catid);
  });
  calculate_sum();
}




// object {hash} contains the attributes of the item that should be created.
// anchor_d {string} is the item designator before which the newly generated item will be inserted.
// add_new {boolean} causes always a new item to be created. no incrementation is done.
function add_new_item(object, add_new, anchor_d) {
  d = object.d;
  catid = object.ci;
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
    label = compose_label(object);
    new_item = $(resources.templates.item.replace(/DESIGNATOR/g, d).replace(/COUNT/g, 1).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, '').replace(/PRICE/g, object.p).replace(/LABEL/g, label).replace(/OPTIONSNAMES/g, '').replace(/SCRIBE/g, '').replace(/CATID/g, catid).replace(/CURRENCY/g, i18n.currency_unit));
    if (anchor_d) {
      $(new_item).insertBefore($('#item_'+anchor_d));
    } else {
      $('#itemstable').prepend(new_item);
    }
    $('#tablerow_' + d + '_count').addClass('updated');
    render_options(resources.c[catid].o, d, catid);
    if (settings.workstation) { enable_keyboard_for_items(object.d); }
  }
  calculate_sum();
  return d
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

function compose_label(object){
  if ( object.hasOwnProperty('qid') || object.hasOwnProperty('qi')) {
    label = object.pre + ' ' + object.n + ' ' + object.post;
  } else {
    label = object.n;
  }
  return label;
}

function clone_item(d) {
  if (items_json[d].c > 1 && permissions.add_option_to_sent_item == false) {
    var clone_d = add_new_item(items_json[d], true, d);
    decrement_item(d);
    d = clone_d;
  }
  return d
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