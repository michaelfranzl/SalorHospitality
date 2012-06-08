/*
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
*/

/* ======================================================*/
/* ================= GLOBAL POS VARIABLES ===============*/
/* ======================================================*/

var new_order = true;
var option_position = 0;
var item_position = 0;
var payment_method_uid = 0;

var resources = {};
var plugin_callbacks_done = [];
var permissions = {};
var items_json = {};
var submit_json = {currentview:'tables'};
var items_json_queue = {};
var submit_json_queue = {};
var customers_json = {};

var timeout_update_tables = 20;
var timeout_update_item_lists = 60;
var timeout_update_resources = 180;
var timeout_refresh_queue = 5;

var counter_update_resources = timeout_update_resources;
var counter_update_tables = timeout_update_tables;
var counter_update_item_lists = timeout_update_item_lists;
var counter_refresh_queue = timeout_refresh_queue;

/* ======================================================*/
/* ==================== DOCUMENT READY ==================*/
/* ======================================================*/

$(function(){
  update_resources();
  update_item_lists();
  if (typeof(manage_counters_interval) == 'undefined') {
    manage_counters_interval = window.setInterval("manage_counters();", 1000);
  }
  if (!_get('customers.button_added'))
    connect('customers_entry_hook','after.go_to.table',add_customers_button);
})


/* ======================================================*/
/* ============ DYNAMIC VIEW SWITCHING/ROUTING ==========*/
/* ======================================================*/
/*
   Allows us to latch onto events in the UI for adding menu items, i.e. in this case, customers, but later more.
 */
function emit(msg,packet) {
  $('body').triggerHandler({type: msg, packet:packet});
}

function connect(unique_name,msg,fun) {
  var pcd = _get('plugin_callbacks_done');
  if (!pcd)
    pcd = [];
  if (pcd.indexOf(unique_name) == -1) {
    $('body').on(msg,fun);
    pcd.push(unique_name);
  }
  _set('plugin_callbacks_done',pcd)
}
function _get(name) {
  return $.data(document.body,name);
}
function _set(name,value) {
  return $.data(document.body,name,value);
}

function route(target, model_id, action, options) {
  emit('before.go_to.' + target, {model_id:model_id, action:action, options:options});
  scroll_to($('#container'),20);
  //debug('GOTO | table=' + table_id + ' | target=' + target + ' | action=' + action + ' | order_id=' + order_id + ' | target_table_id=' + target_table_id, true);
  // ========== GO TO TABLES ===============
  if ( target == 'tables' ) {
    submit_json.target = 'tables';
    $('#orderform').hide();
    $('#invoices').hide();
    $('#items_notifications').hide();
    $('#tables').show();
    $('#rooms').hide();
    //$('#order_cancel_button').show();
    $('#functions_header_index').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_invoice_form').hide();
    $('#functions_footer').hide();
    $('#customer_list').hide();
    $('#tablesselect').hide();
    if (action == 'destroy') {
      submit_json.model.hidden = true;
      submit_json.jsaction = 'send';
      send_json('table_' + model_id);
    } else if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
    } else if (action == 'move') {
      $(".tablesselect").slideUp();
      submit_json.jsaction = 'move';
      submit_json.target_table_id = options.target_table_id;
      send_json('table_' + model_id);
    } else {
      submit_json = {};
      items_json = {};
    }
    screenlock_counter = settings.screenlock_timeout;
    option_position = 0;
    item_position = 0;
    counter_update_tables = timeout_update_tables;
    update_tables();
    submit_json.currentview = 'tables';

  // ========== GO TO TABLE ===============
  } else if ( target == 'table') {
    submit_json.target = 'table';
    submit_json.model = {table_id:model_id};
    $('#order_sum').html('0' + i18n.decimal_separator + '00');
    $('#order_info').html(i18n.just_order);
    $('#order_note').val('');
    $('#inputfields').html('');
    $('#itemstable').html('');
    $('#articles').html('');
    $('#quantities').html('');
    if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
    } else if (action == 'send_and_print' ) {
      submit_json.jsaction = 'send_and_print';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
    } else if (false && submit_json_queue.hasOwnProperty('table_' + model_id)) {
      debug('Offline mode. Fetching items from queue');
      $('#order_cancel_button').hide();
      submit_json = submit_json_queue['table_' + model_id];
      items_json = items_json_queue['table_' + model_id];
      delete submit_json_queue['table_' + model_id];
      delete items_json_queue['table_' + model_id];
      render_items();
    } else if (action == 'specific_order') {
      submit_json = {model:{table_id:model_id}};
      items_json = {};
      $.ajax({ type: 'GET', url: '/tables/' + model_id + '?order_id=' + options.order_id, timeout: 5000 }); //this repopulates items_json and renders items
    } else {
      submit_json = {model:{table_id:model_id}};
      items_json = {};
      $.ajax({ type: 'GET', url: '/tables/' + model_id, timeout: 5000 }); //this repopulates items_json and renders items
    }
    $('#orderform').show();
    $('#invoices').hide();
    $('#tables').hide();
    $('#items_notifications').hide();
    $('#areas').hide();
    $('#rooms').hide();
    $('#functions_header_index').hide();
    $('#functions_header_invoice_form').hide();
    $('#functions_header_order_form').show();
    if (settings.mobile) { $('#functions_footer').show(); }
    screenlock_counter = -1;
    counter_update_tables = -1;
    submit_json.currentview = 'table';

  // ========== GO TO INVOICE ===============
  } else if ( target == 'invoice') {
    submit_json.target = 'invoice';
    if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      submit_json.model = {table_id:model_id};
      send_json('table_' + model_id);
    }
    $('#invoices').html('');
    $('#invoices').show();
    $('#items_notifications').hide();
    $('#orderform').hide();
    $('#tables').hide();
    $('#rooms').hide();
    $('#inputfields').html('');
    $('#itemstable').html('');
    $('#functions_header_invoice_form').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_index').hide();
    $('#functions_footer').hide();
    counter_update_tables = -1;
    screenlock_counter = -1;
    submit_json['payment_methods'] = {};
    submit_json['totals'] = {};
    submit_json.currentview = 'invoice';

  // ========== GO TO ROOMS ===============
  } else if ( target == 'rooms' ) {
    submit_json.target = 'rooms';
    $('#booking_form').hide();
    $('#tables').hide();
    $('#areas').hide();
    $('#rooms').show();
    $('#functions_header_index').show();
    if (action == 'destroy') {
      submit_json.model.hidden = true;
      submit_json.jsaction = 'send';
      send_json('booking_' + model_id);
    } else if (action == 'send') {
      submit_json.jsaction = 'send';
      send_json('booking_' + model_id);
    } else if (action == 'pay') {
      submit_json.jsaction = 'pay';
      send_json('booking_' + model_id);
    } else {
      submit_json = {};
      items_json = {};
    }
    $('.booking_form').remove();
    screenlock_counter = settings.screenlock_timeout;
    option_position = 0;
    item_position = 0;
    counter_update_tables = timeout_update_tables;
    submit_json.currentview = 'rooms';

  // ========== GO TO ROOM ===============
  } else if ( target == 'room' ) {
    $('#rooms').hide();
    $('#areas').hide();
    $('#tables').hide();
    $('#functions_header_index').hide();
    submit_json = {currentview:'room', model:{room_id:model_id, season_id:null, room_type_id:null}, items:{}};
    items_json = {};
    window.display_booking_form(model_id);
    $.ajax({ type: 'GET', url: '/rooms/' + model_id, timeout: 5000 }); //this repopulates items_json and renders items
  }
  emit('after.go_to.' + target, {model_id:model_id, action:action, options:options});
}

/* ======================================================*/
/* ============ JSON SENDING AND QUEUEING ===============*/
/* ======================================================*/
function send_json(object_id) {
  // copy main jsons to queue
  submit_json_queue[object_id] = submit_json;
  items_json_queue[object_id] = items_json;
  // reset main jsons
  submit_json = {model:{}};
  items_json = {};
  // send the queue
  send_queue(object_id);
}

function send_queue(object_id) {
  debug('SEND QUEUE table ' + object_id);
  $.ajax({
    type: 'post',
    url: '/orders/update_ajax',
    data: submit_json_queue[object_id],
    timeout: 20000,
    complete: function(data,status) {
      update_tables();
      if (status == 'timeout') {
        debug("TIMEOUT from server");
      } else if (status == 'success') {
        clear_queue(object_id);
      } else if (status == 'error') {
        debug('ERROR from server: ' + JSON.stringify(data));
        clear_queue(object_id); // server is not really offline, so no offline behaviour.
      } else if (status == 'parsererror') {
        debug('Parser error from server: ' + data);
        clear_queue(object_id); // server is not really offline, so no offline behaviour.
      }
    }
  });
}

function clear_queue(i) {
  debug('CLEAR QUEUE table ' + i);
  delete submit_json_queue[i];
  delete items_json_queue[i];
  $('#queue_'+i).remove();
}

function display_queue() {
  $('#queue').html('');
  jQuery.each(submit_json_queue, function(k,v) {
    var link = $(document.createElement('a'));
    link.attr('id','queue_'+k);
    var div = $(document.createElement('div'));
    div.html('Re-send ' + k);
    (function(){
      var id = k;
      link.on('click', function() {
        send_queue(id);
      })
    })();
    link.append(div);
    $('#queue').append(link);
  });
}


/* =========================================================*/
/* ============ JSON POPULATING AND MANAGING ===============*/
/* =========================================================*/

function create_json_record(model, object) {
  d = object.d;
  item_position += 10;
  if (typeof(object.s) == 'undefined') {
    s = item_position;
  } else {
    s = object.s;
  }
  if (items_json.hasOwnProperty(d)) {
    d += 'c'; // c for cloned. this happens when an item is split during option add.
    s += 1;
  }
  if (model == 'order') {
    items_json[d] = {ai:object.ai, qi:object.qi, d:d, c:1, o:'', t:{}, i:[], p:object.p, pre:'', post:'', n:object.n, s:s, ci:object.ci};
  } else if (model == 'booking') {
    items_json[d] = {guest_type_id:object.guest_type_id, count:1, surcharges:{}}
  }
  if ( ! object.hasOwnProperty('qi')) { delete items_json[d].qi; }
  create_submit_json_record(model,d,items_json[d]);
  return d;
}

// this creates a new record, copied from items_json, which must exist
function create_submit_json_record(model, d, object) {
  if( !submit_json.hasOwnProperty('items')) { submit_json.items = {}; };
  if( !submit_json.items.hasOwnProperty(d)) {
    if (model == 'order') {
      submit_json.items[d] = {id:object.id, ai:object.ai, qi:object.qi, s:object.s};
    } else if (model == 'booking') {
      submit_json.items[d] = {id:object.id, guest_type_id:object.guest_type_id};
    }
    // remove redundant fields
    if (items_json[d].hasOwnProperty('id')) {
      delete submit_json.items[d].ai;
      delete submit_json.items[d].qi;
    }
    if ( ! items_json[d].hasOwnProperty('qi')) {
      delete submit_json.items[d].qi;
    }
  }
}

function set_json(model, d, attribute, value) {
  if (items_json.hasOwnProperty(d)) {
    items_json[d][attribute] = value;
  } else {
    //alert('Unexpected error: Object items_json doesnt have the key ' + d + ' yet');
  }
  if ( attribute != 't' ) {
    // never copy the options object to submit_json
    create_submit_json_record(model, d, items_json[d]);
    submit_json.items[d][attribute] = value;
  }
}


/* ========================================================*/
/* ============ DYNAMIC RENDERING FROM JSON ===============*/
/* ========================================================*/

function render_items() {
  jQuery.each(items_json, function(k,object) {
    catid = object.ci;
    tablerow = resources.templates.item.replace(/DESIGNATOR/g, object.d).replace(/COUNT/g, object.c).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, object.o).replace(/PRICE/g, object.p).replace(/LABEL/g, compose_label(object)).replace(/OPTIONSNAMES/g, compose_optionnames(object));
    $('#itemstable').append(tablerow);
    $('#options_select_' + object.d).attr('disabled',true); // option selection is only allowed when count > start count, see increment
    if (settings.workstation) { enable_keyboard_for_items(object.d); }
    render_options(resources.c[catid].o, object.d, catid);
  });
  calculate_sum();
}



/* ===================================================================*/
/* ======= RENDERING ARTICLES, QUANTITIES, ITEMS               =======*/
/* ===================================================================*/
/*
 * find_customer(needle); Searches the customer lookup table
 * for an instance where name.indexOf(needle) != -1
 * returns -1 is there is nothing like it, and -2 if there is no secondary index
 * in theory, lookups should be much faster when the list of customers is very large,
 * this way, it is unecessary to loop through every entry, entries are thus grouped
 * into a 26 long array, where each entry is 26 deep, followed by an array of object
 * entries.
 * {
 *   d: {
 *      do: [
 *        {
 *          id: 1,
 *          name: "Doe, John"
 *        }
 *      ]
 *   },
 *   m: {
 *    ma: [
 *      {
 *        id: 2,
 *        name: "Martin, Jason"
 *      }
 *    ]
 *   }
 * }
 * */
function find_customer(text) {
   var i = 0;
   var c = text[i];
   var results = [];
   if (resources.customers[c]) {
        c2 = c + text[i+1];
        if (resources.customers[c][c2]) {
            for (var j in resources.customers[c][c2]) {
                if (resources.customers[c][c2][j].name.toLowerCase().indexOf(text) != -1) {
                  results.push(resources.customers[c][c2][j]);
                }
            }
            return results;
        } else {
            return -2;
        }
    } else {
        return -1;
    }
}
/*
 * add_category_button(label,options); Adds a new category button.
 * options is a hash like so:
 * {
 *    id: "the_html_id_youd_like",
 *    handlers: {
 *      mouseup: function (event) { alert('mouseup fired'); }
 *      ...
 *    },
 *    bgcolor: '205,0,82',
 *    bgimage: '/images/myimage.png',
 *    border: {
 *      top: '205,0,85',
 *      ... bottom, left, right etc.
 *    }
 * }
 * */
function add_category_button(label,options) {
    var cat = $('<div id="'+options.id+'" class="category"></div>');
    var cat_label = '<div class="category_label"><span>'+label+'</span></div>';
    var styles = [];
    var bgcolor = "background-color: rgb(XXX);";
    var bgimage = "background-image: url('XXX');";
    //var brdrcolor = "border-color: rgb(top) rgb(right) rgb(bottom) rgb(left);";
    //var brdrcolors = {
    //  top: '85,85,85',
    //  right: '34,34,34',
    //  bottom: '34,34,34',
    //  left: '85,85,85'
    //};
    cat.append(cat_label);
    
    for (var type in options.handlers) {
      cat.bind(type,options.handlers[type]);
    }
    for (var attr in options.attrs) {
      cat.attr(attr,options.attrs[attr]);
    }
    
    if (options.bgcolor) {
      styles.push(bgcolor.replace("XXX",options.bgcolor));
    }
    if (options.bgimage) {
      styles.push(bgimage.replace("XXX",options.bgimage));
    }
    //if (options.border) {
    //  for (var pos in options.border) {
    //    brdrcolor = brdrcolor.replace(pos,options.border[pos]);
    //  }
    //}
    //// Default border colors added later
    //for (var pos in brdrcolors) {
    //  brdrcolor = brdrcolor.replace(pos,brdrcolors[pos]);
    //}
    //styles.push(brdrcolor);
    cat.attr('style',styles.join(' '));
    $(options.append_to).append(cat);
}

function customer_search(term) {
  var c = term.substr(0,1).toLowerCase();
  var c2 = term.substr(0,2).toLowerCase();
  var results = [];
  if (resources.customers[c]) {
    if (resources.customers[c][c2]) {
      for (var i in resources.customers[c][c2]) {
        if (resources.customers[c][c2][i].name.toLowerCase().indexOf(term.toLowerCase()) != -1) {
          results.push(resources.customers[c][c2][i]);
        }
      }
      return results;
    } else {
      return [];
    }
  } else {
    return [];
  }
}

function add_customer_button(qcontainer,customer,active) {
  var abutton = $(document.createElement('div'));
  abutton.addClass('quantity customer-entry');
  abutton.html(customer.name);
  if (active) abutton.removeClass("quantity").addClass("active quantity");
  (function() {
    var element = abutton;
    var cust = customer;
    abutton.on('mouseup', function(){
      highlight_button(element);
      submit_json.model['customer_id'] = cust.id
    });
  })();
  (function() { 
    var element = abutton;
    abutton.on('click', function() {
      highlight_border(element);
      if (settings.workstation) {
        $('.quantities').slideUp();
      } else {
        $('.quantities').html('');
      }
    });
  })();
  qcontainer.append(abutton);
  return qcontainer;
}

function onCustomerSearchAccept(){
  if ($('#customer_search_input').val().length >= 3) {
    var results = customer_search($('#customer_search_input').val());
    if (results.length > 0) {
      var qcont = $("#customers_list");
      $('.customer-entry').remove();
      for (var i in results) {
        qcont = add_customer_button(qcont,results[i],false);
      }
    }
  }
}

function show_customers(append_to) {
  $('#articles').html('');
  var qcontainer = $('<div id="customers_list"></div>');
  qcontainer.addClass('quantities');
  var search_box = $('<input id="customer_search_input" value="" />');
  search_box.change(onCustomerSearchAccept);
  search_box.keyboard( {openOn: '', accepted: onCustomerSearchAccept } );
  search_box.click(function(){
    search_box.getkeyboard().reveal();
  });
  qcontainer.append(search_box);
  for (i in customers_json) {
    qcontainer = add_customer_button(qcontainer,customers_json[i],true);
  }
  for (i in resources.customers.regulars) {
    if (in_array_of_hashes(customers_json,"id",resources.customers.regulars[i].id)) {
      continue;
    }
    qcontainer = add_customer_button(qcontainer,resources.customers.regulars[i],false);
  }
  $('#articles').append(qcontainer);
  $(append_to).append(qcontainer);
}

function display_articles(cat_id) {
  $('#articles').html('');
  jQuery.each(resources.c[cat_id].a, function(art_id,art_attr) {
    a_object = this;
    var abutton = $(document.createElement('div'));
    abutton.addClass('article');
    abutton.html(art_attr.n);
    var qcontainer = $(document.createElement('div'));
    qcontainer.addClass('quantities');
    qcontainer.css('display','none');
    qcontainer.attr('id','article_' + art_id + '_quantities');
    (function() {
      var element = abutton;
      abutton.on('mouseup', function(){
        highlight_button(element);
      });
    })();
    $('#articles').append(abutton);
    if (jQuery.isEmptyObject(resources.c[cat_id].a[art_id].q)) {
      (function() { 
        var element = abutton;
        var object = a_object;
        abutton.on('click', function() {
          highlight_border(element);
          if (settings.workstation) {
            $('.quantities').slideUp();
          } else {
            $('.quantities').html('');
          }
          add_new_item(object, false);
        });
      })();
    } else {
      // quantity
      arrow = $(document.createElement('img'));
      arrow.addClass('more');
      arrow.attr('src','/assets/more.png');
      abutton.append(arrow);
      (function() {
        abutton.on('click', function(event) {
          var quantities = resources.c[cat_id].a[art_id].q;
          var target = qcontainer;
          var catid = cat_id;
          display_quantities(quantities, target, catid);
        });
      })();
      qcontainer.insertAfter(abutton);
    }
  });
}

function display_quantities(quantities, target, cat_id) {
  if (settings.workstation) {
    target.html('');
    $('.quantities').hide();
  } else if (target.html() != '') {
    target.html('');
    return;
  }

  //target.css('display','none');
  target.html('');
  jQuery.each(quantities, function(qu_id,qu_attr) {
    q_object = this;
    qbutton = $(document.createElement('div'));
    qbutton.addClass('quantity');
    //qbutton.css('display','none');
    qbutton.html(qu_attr.pre + qu_attr.post);
    (function() {
      var element = qbutton;
      var quantity = q_object;
      qbutton.on('click', function(event) {
        add_new_item(quantity,false);
        highlight_button(element);
        highlight_border(element);
      });
    })();
    target.append(qbutton);
  })
  if (settings.workstation) {
    target.slideDown();
  } else {
    target.show();
  }
  
}

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
    // selected item is already there
    increment_item(d);
  } else {
    d = create_json_record('order', object);
    label = compose_label(object);
    new_item = $(resources.templates.item.replace(/DESIGNATOR/g, d).replace(/COUNT/g, 1).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, '').replace(/PRICE/g, object.p).replace(/LABEL/g, label).replace(/OPTIONSNAMES/g, ''));
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

function customer_list_entry(customer) {
  var entry = $('<div class="entry" customer_id="' + customer['id'] + '" id="customer_entry_' + customer['id'] + '"></div>');
  entry.mousedown(function () {
    var id = '#customer_name_' + $(this).attr('customer_id');
    var field = $('<input type="hidden" name="order[customer_set][][id]" value="' + $(this).attr('customer_id') + '"/>');
    $("#order_form_ajax").append(field);
    $('#order_info').append("<span class='order-customer'>"+$(id).html()+"</span>");
  });
  entry.append("<span class='option' id='customer_name_" + customer['id'] + "'>" + customer['first_name'] + " " + customer['last_name'] + "</span>");
  return entry;
}

function customer_list_update() {
  $.getJSON('/customers?format=json&keywords=' + $('#customer_search').val() , function (data) {
    $('#customer_list_target').html('');
    for (i in data) {
      $('#customer_list_target').append(customer_list_entry(data[i]['customer']));
    }
  });
}

/* ========================================================*/
/* ================== POS FUNCTIONALITY ===================*/
/* ========================================================*/

function add_payment_method(order_id) {
  payment_method_uid += 1;
  pm_row = $(document.createElement('div'));
  pm_row.addClass('payment_method_row');
  pm_row.attr('id', 'payment_method_row' + payment_method_uid);
  submit_json.payment_methods[order_id][payment_method_uid] = {id:null, amount:0};
  $.each(resources.pm, function(k,v) {
    pm_button = $(document.createElement('span'));
    pm_button.addClass('payment_method');
    pm_button.html(v.n);
    (function() {
      var uid = payment_method_uid;
      pm_button.on('click', function() {
        submit_json.payment_methods[order_id][uid].id = v.id;
        $('#payment_method_row' + uid + ' span').removeClass('selected');
        $(this).addClass('selected');
        $('#payment_method_' + uid + '_amount').select();
        if(settings.workstation) {
          $('#payment_method_'+ uid + '_amount').select();
          //$('#payment_method_row'+ uid + ' .ui-keyboard-input').select();
        }
      });
    })();
    pm_row.append(pm_button);
  });
  pm_input = $(document.createElement('input'));
  pm_input.attr('type', 'text');
  pm_input.attr('id', 'payment_method_' + payment_method_uid + '_amount');
  if (settings.workstation) {
    pm_input.keyboard({
      openOn: 'click',
      accepted: function(){ 
        payment_method_input_change(pm_input, payment_method_uid, order_id)
      },
      layout:'num'
    });
  }
  (function() {
    var uid = payment_method_uid;
    var oid = order_id;
    pm_input.on('keyup', function(){
      payment_method_input_change(this, uid, oid);
    });
  })();
  pm_row.append(pm_input);
  $('#model_' + order_id + ' #payment_methods_container').append(pm_row);
}

function payment_method_input_change(element, uid, oid) {
  amount = $(element).val();
  amount = amount.replace(',','.');
  if (amount == '') { amount = 0; }
  submit_json.payment_methods[oid][uid].amount = parseFloat(amount);
  payment_method_total = 0;
  $.each(submit_json.payment_methods[oid], function(k,v) {
    payment_method_total += v.amount;
  });
  submit_json.totals[oid].payment_methods = payment_method_total;
  change = - ( submit_json.totals[oid].model - payment_method_total);
  if (change < 0 ) { change = 0 };
  $('#change_' + oid).html(number_to_currency(change));
}



function remove_payment_method_by_name(name) {
  if (!submit_json.payment_methods)
    return;
  npms = [];
  for (var i in submit_json.payment_methods) {
    if (!submit_json.payment_methods[i].name == name) {
      npms.push(submit_json.payment_methods[i]);
    }
  }
  submit_json.payment_methods = npms;
}

function increment_item(d) {
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
  if ( i > 1 && ( permissions.decrement_items || i > start_count ) ) {
    i--;
    set_json('order', d, 'c', i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
    if ( i == start_count ) { $('#tablerow_' + d + '_count').removeClass('updated'); }
  } else if ( i == 1 && ( permissions.decrement_items || ( ! d.hasOwnProperty('id') ))) {
    i--;
    set_json('order', d, 'c', i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
    if (permissions.delete_items) {
      set_json('order', d, 'x', true);
      $('#item_' + d).fadeOut('slow');
    }
  }
  if (settings.mobile) { permit_select_open(d, i, start_count); }
  calculate_sum();
}

function item_changeable(count, start_count) {
  return ( (typeof(start_count) == 'undefined') || count > start_count )
}

function permit_select_open(d, count, start_count) {
  if ( item_changeable(count, start_count) ) {
    $('#options_select_' + d).attr('disabled',false);
  } else {
    $('#options_select_' + d).attr('disabled',true);
  }
}

function clone_item(d) {
  if (items_json[d].c > 1) {
    var clone_d = add_new_item(items_json[d], true, d);
    decrement_item(d);
    d = clone_d;
  }
  return d
}

function add_option_to_item(d, value, cat_id) {
  if (value != -1) {
    $('#options_div_' + d).slideUp();
    d = clone_item(d);
  }
  if (value == 0) {
    // delete all options
    set_json('order', d, 'i', [0]);
    set_json('order', d, 't', {});
    $('#optionsnames_' + d).html('');
  } else {
    var optionobject = resources.c[cat_id].o[value];
    var option_uid = items_json[d].i.length + 1;
    items_json[d].t[option_uid] = optionobject;
    var stripped_id = value.split('_')[1];
    var list = items_json[d].i;
    list.push(stripped_id);
    set_json('order', d, 'i', list);
    $('#optionsnames_' + d).append('<br>' + optionobject.n);
  }
  calculate_sum();
}


/* ========================================================*/
/* ===================== POS HELPERS ======================*/
/* ========================================================*/

function toggle_order_booking() {
  if (submit_json.currentview == 'tables') {
    route('rooms');
  } else {
    route('tables');
  }
}

function number_with_precision(number, precision) {
  number = number.toFixed(precision);
  number = number.replace('.',i18n.decimal_separator);
  return number;
}

function number_to_currency(number) {
  return i18n.currency_unit + ' ' + number_with_precision(number, 2);
}

function render_options(options, d, cat_id) {
  jQuery.each(options, function(key,object) {
    if (settings.workstation) {
      button = $(document.createElement('span'));
      button.html(object.n);
      button.addClass('option');
      (function() {
        var cid = cat_id;
        var o = object;
        button.on('click',function(){
          add_option_to_item(d, o.s + '_' + o.id, cid);
        });
      })();
      $('#options_div_' + d).append(button);
    } else if (settings.mobile) {
      option_tag = $(document.createElement('option'));
      option_tag.html(object.n);
      var s = object.s == null ? 0 : object.s;
      option_tag.val(s + '_' + object.id);
      $('#options_select_' + d).append(option_tag);
    }
  });
}

function compose_label(object){
  if ( object.hasOwnProperty('qid') || object.hasOwnProperty('qi')) {
    //object_type = 'quantity';
    label = object.pre + ' ' + object.n + ' ' + object.post;
  } else {
    //object_type = 'article';
    label = object.n;
  }
  return label;
}

function compose_optionnames(object){
  names = '';
  jQuery.each(object.t, function(k,v) {
    names += (v.n + '<br>')
  });
  if (object.u < -10) {
  // add course number
    names += (object.u + 10) * -1 + '. Gang'
  }
  return names;
}

function calculate_sum() {
  var sum = 0;
  jQuery.each(items_json, function() {
    var count = this.c;
    sum += count * this.p;
    // now add option prices from object t
    jQuery.each(this.t, function() {
      sum += this.p * count;
    });
  });
  $('#order_sum').html(sum.toFixed(2).replace('.', i18n.decimal_separator));
  return sum;
}

function display_configuration_of_item(d) {
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

  scribe_button =  $(document.createElement('span'));
  scribe_button.addClass('item_scribe');
  scribe_button.on('click', function(){ init_scribe(d); });
  cell.append(scribe_button);

  row.html(cell);
  row.addClass('item');
  row.insertAfter('#item_' + d);
}


/* ========================================================*/
/* ================== PERIODIC FUNCTIONS ==================*/
/* ========================================================*/

function manage_counters() {
  counter_update_resources -= 1;
  counter_update_tables -= 1;
  counter_update_item_lists -= 1;
  counter_refresh_queue -= 1;

  if (counter_update_resources == 0) {
    update_resources();
    counter_update_resources = timeout_update_resources;
  }

  if (counter_update_item_lists == 0) {
    update_item_lists();
    counter_update_item_lists = timeout_update_item_lists;
  }

  if (counter_update_tables == 0) {
    update_tables();
    counter_update_tables = timeout_update_tables;
  }

  if (counter_refresh_queue == 0) {
    display_queue();
    counter_refresh_queue = timeout_refresh_queue;
  }
  return 0;
}

function update_tables(){
  $.ajax({
    url: '/tables',
    timeout: 2000
  });
}

function update_resources() {
  $.ajax({
    url: '/vendors/render_resources',
    dataType: 'script',
    complete: function(data,state) { update_resouces_success(data) },
    timeout: 3000
  });
}

function update_resouces_success(data) {
  emit('ajax.update_resources.success', data);
}


function update_item_lists() {
  $.ajax({
    url: '/items/list?scope=preparation',
    timeout: 2000
  });
  $.ajax({
    url: '/items/list?scope=delivery',
    timeout: 2000
  });
}

function change_item_status(id,status) {
  $.ajax({
    type: 'POST',
    url: '/items/change_status?id=' + id + '&status=' + status
  });
}


/* ========================================================*/
/* =================== USER INTERFACE =====================*/
/* ========================================================*/

function add_customers_button() {
  //if(_get('customers.button_added'))
  //  return
  opts = {id:'customers_category_button', handlers:{'mouseup':function(){show_customers('#articles')}}, bgcolor:"50,50,50", bgimage:'/assets/category_customer.png', append_to:'#categories'};
  add_category_button(i18n.customers, opts);
  //_set('customers.button_added',true);
}

function highlight_button(element) {
  $(element).effect("highlight", {}, 300);
}

function highlight_border(element) {
  $(element).css('borderColor', 'white');
}

function restore_border(element) {
  $(element).css({ borderColor: '#555555 #222222 #222222 #555555' });
}

function deselect_all_categories() {
  var container = $('#categories');
  var cats = container.children();
  for(c in cats) {
    if (cats[c].style) {
      cats[c].style.borderColor = '#555555 #222222 #222222 #555555';
    }
  }
}

function category_onmousedown(category_id, element) {
  display_articles(category_id);
  deselect_all_categories();
  highlight_border(element);
  if (settings.mobile) {
    if (settings.mobile_special) {
      y = $('#articles').position().top;
      window.scrollTo(0,y);
    } else {
      scroll_to('#articles', 7);
    }
  }
}

function setup_payment_method_keyboad(pmid,id) {
  $("#" + id).keyboard( 
          { 
            openOn: 'focus',
            layout: 'num',
            accepted: function(){ 
              $.ajax({
                  url: "/orders/update?currentview=update_pm&pid=" +pmid+ "&amount=" + $("#" + id).val(), 
                  type: 'PUT'
                 }); 
            } } 
          );
}
