/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/* ======================================================*/
/* ================= GLOBAL POS VARIABLES ===============*/
/* ======================================================*/

var upper_delivery_time_limit = 45 * 60000;

var invoice_update = true;
var get_table_show_retry = true;
var offline_tables = {};
var last_table_id = null;

var new_order = true;
var option_position = 0;
var item_position = 0;
var payment_method_uid = 0;
var audio_enabled = true;

var resources = {};
var plugin_callbacks_done = [];
var permissions = {};
var intervals = {};
var items_json = {};
var submit_json = {model:{}};
var items_json_queue = {};
var submit_json_queue = {};
var customers_json = {};

var timeout_update_tables = 19;
var timeout_update_item_lists = 31;
var timeout_update_resources = 127;
var timeout_refresh_queue = 4;

var counter_update_resources = timeout_update_resources;
var counter_update_tables = 3;
var counter_update_item_lists = 3;
var counter_refresh_queue = timeout_refresh_queue;
/* ======================================================*/
/* ==================== DOCUMENT READY ==================*/
/* ======================================================*/

$(function(){
  update_resources('documentready');
  if (typeof(manage_counters_interval) == 'undefined') {
    manage_counters_interval = window.setInterval("manage_counters();", 1000);
  }
  if (!_get('customers.button_added')) connect('customers_entry_hook','after.go_to.table',add_customers_button);
})


/* ======================================================*/
/* ============ DYNAMIC VIEW SWITCHING/ROUTING ==========*/
/* ======================================================*/


function route(target, model_id, action, options) {
  //debug("route(" + target + ", " + model_id + ", " + action + ", " + options + ")");
  //emit('before.go_to.' + target, {model_id:model_id, action:action, options:options});
  
  // ========== GO TO TABLES ===============
  if ( target == 'tables' ) {    
    submit_json.target = 'tables';
    invoice_update = true;
    get_table_show_retry = false;
    $('#orderform').hide();
    $('#invoices').hide();
    $('#items_notifications_interactive').hide();
    $('#items_notifications_static').show();
    $('#tables').show();
    $('#rooms').hide();
    $('#spliced_seasons').hide();
    if (settings.mobile) { $('#areas').show(); }
    $('#functions_header_index').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_invoice_form').hide();
    $('#functions_footer').hide();
    $('#functions_header_last_invoices').hide();
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
      items_json = {};
    }
    screenlock_counter = settings.screenlock_timeout;
    option_position = 0;
    item_position = 0;
    counter_update_tables = timeout_update_tables;
    update_tables();
    if (settings.mobile && typeof(model_id) != 'undefined') {
      scroll_to($('#table' + model_id), 20);
    } else {
      scroll_to($('#container'),20);
    }
    submit_json = {model:{}};
    submit_json.currentview = 'tables';

  // ========== GO TO TABLE ===============
  } else if ( target == 'table') {
    scroll_to($('#container'),20);
    invoice_update = true;
    get_table_show_retry = true;
    $('#order_sum').html('0' + i18n.decimal_separator + '00');
    switch_to_table();
    screenlock_counter = -1;
    counter_update_tables = -1;
    if (action == 'send') {
      // finish order
      submit_json.jsaction = 'send';
      submit_json.target = 'table_no_invoice_print';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
      // stay on table
      submit_json.model.table_id = model_id; // this is neccessary because send_json will clear the submit_json.model. since we stay on the table, we need to re-set the table_id.
      //final rendering will be done in application#route
    } else if (action == 'customer_request_send') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_send';
      alert(i18n.order_will_be_confirmed);
      send_json('table_' + model_id);
    } else if (action == 'customer_request_finish') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_finish';
      alert(i18n.finish_was_requested);
      send_json('table_' + model_id);
    } else if (action == 'customer_request_waiter') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_waiter';
      alert(i18n.waiter_was_requested);
      send_json('table_' + model_id);
    } else if (action == 'send_and_print' ) {
      // finish and print order receipt
      submit_json.jsaction = 'send';
      submit_json.target = 'table_do_invoice_print';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
      // stay on table
      submit_json.model.table_id = model_id; // this is neccessary because send_json will clear the submit_json.model. since we stay on the table, we need to re-set the table_id.
      //final rendering will be done in application#route
    } else if (submit_json_queue.hasOwnProperty('table_' + model_id)) {
      submit_json = $.extend(true, {}, submit_json_queue['table_' + model_id]); // deep copy
      items_json = $.extend(true, {}, items_json_queue['table_' + model_id]); // deep copy
      delete submit_json_queue['table_' + model_id];
      delete items_json_queue['table_' + model_id];
      render_items();
      if (((new Date).getTime()) - submit_json.sent_at > 40000) {
        // the order could still be processed by the server. do not warn the user about offline items within a certain time period.
        $('#order_cancel_button').hide();
        send_email('route(): User has been informed about offline items', '');
        var answer = confirm(i18n.table_contains_offline_items);
        if (answer == true) {
          route('tables',model_id,'send'); //send_json('table_' + model_id);
          return;
        }
      }
    } else if (action == 'specific_order') {
      $.ajax({
        type: 'GET',
        url: '/tables/' + model_id + '?order_id=' + options.order_id,
        timeout: 15000
      }); //this repopulates items_json and renders items
    } else if (action == 'from_booking') {
      submit_json.jsaction = 'send_and_go_to_table';
      send_json('booking_' + options.booking_id);
      submit_json.model.table_id = model_id;
    } else {
      // regular click on a table from main view
      get_table_show(model_id);
    }
    // clean workspace up
    submit_json = {model:{}};
    submit_json.model.table_id = model_id;
    submit_json.currentview = 'table';

  // ========== GO TO INVOICE ===============
  } else if ( target == 'invoice') {
    submit_json.target = 'invoice';
    if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      send_json('table_' + model_id);
      // invoice form will be rendered by the server as .js.erb template. see application#route
    }
    $('#invoices').html('');
    $('#invoices').show();
    $('#items_notifications_interactive').hide();
    $('#spliced_seasons').hide();
    //$('#items_notifications_static').hide();
    $('#orderform').hide();
    $('#tables').hide();
    $('#rooms').hide();
    $('#areas').hide();
    //$('#screenwait').hide();
    //$('#inputfields').html('');
    $('#itemstable').html('');
    $('#functions_header_invoice_form').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_index').hide();
    $('#functions_footer').hide();
    counter_update_tables = -1;
    screenlock_counter = -1;
    // clean workspace up
    submit_json = {model:{},split_items_hash:{},totals:{},payment_method_items:{}};
    submit_json.currentview = 'invoice';

  // ========== GO TO ROOMS ===============
  } else if ( target == 'rooms' ) {
    if ((navigator.userAgent.indexOf('Chrom') == -1 && navigator.userAgent.indexOf('WebKit') == -1) && typeof(i18n) != 'undefined') {
      $('#main').html('');
      create_dom_element('div',{id:'message'}, i18n.browser_warning, '#main');
      return;
    }
    scroll_to($('#container'),20);
    submit_json.target = 'rooms';
    // See bookings.js show_rooms_interface() I did this because the showing/hiding, and doing of stuff needs
    // to be in its own function so that it can be attached to click handlers
    emit("salor_hotel.render_rooms",{model_id:model_id, action:action, options:options});
    _set("salor_hotel.bookings.dirty",true);
    if (action == 'destroy') {
      submit_json.model.hidden = true;
      submit_json.jsaction = 'send';
      send_json('booking_' + model_id);
    } else if (action == 'send') {
      submit_json.jsaction = 'send';
      emit("send.booking",submit_json);
      send_json('booking_' + model_id);
    } else if (action == 'update_bookings') {
      update_booking_for_room(model_id,options);
    } else {
      submit_json.model = {};
      items_json = {};
    }
    $('.booking_form').remove();
    screenlock_counter = settings.screenlock_timeout;
    option_position = 0;
    item_position = 0;
    counter_update_tables = timeout_update_tables;
    submit_json.currentview = 'rooms';

  // ========== NEW BOOKING ===============
  } else if ( target == 'room' ) {
    scroll_to($('#container'),20);
    $('#rooms').hide();
    $('#areas').hide();
    $('#tables').hide();
    $('#rooms').hide();
    $('#container').show();
    $('#spliced_seasons').show();
    $('#functions_header_index').hide();
    $('#functions_header_order_form').hide();
    //$('#items_notifications_interactive').hide();
    $('#items_notifications_static').hide();
    submit_json = {currentview:'room', model:{room_id:model_id, room_type_id:null, duration:1}, items:{}};
    surcharge_headers = {guest_type_set:[], guest_type_null:[]};
    _set('surcharge_headers', surcharge_headers);
    items_json = {};
    $.ajax({ type: 'GET', url: '/rooms/' + model_id, timeout: 15000 }); //this repopulates items_json and renders items
    window.display_booking_form(model_id);

  // ========== EXISTING BOOKING ===============
  } else if (target == 'booking') {
    scroll_to($('#container'),20);
    $('#rooms').hide();
    $('#areas').hide();
    $('#tables').hide();
    $('#rooms').hide();
    //$('.booking_form').remove();
    $('#container').show();
    $('#orderform').hide();
    $('#invoices').hide();
    $('#spliced_seasons').show();
    
    $('#functions_header_index').hide();
    $('#functions_header_order_form').hide();
    //$('#items_notifications_interactive').hide();
    $('#items_notifications_static').hide();
    if (typeof(options) == 'undefined') {
      room_id = null;
    } else {
      room_id = options.room_id;
    }
    submit_json = {currentview:'room', model:{room_id:room_id, room_type_id:null, duration:1}, items:{}};
    surcharge_headers = {guest_type_set:[], guest_type_null:[]};
    _set('surcharge_headers', surcharge_headers);
    items_json = {};
    $.ajax({ type: 'GET', url: '/bookings/' + model_id, timeout: 15000 });
    window.display_booking_form(room_id);
    
  // ========== REDIRECT ===============
  // these cases don't need static view switching/rendering. the rendering is enterely done by the server.
  } else if (target == 'redirect') {
    scroll_to($('#container'),20);
    
    if (action == 'booking_interim_invoice') {
      submit_json.jsaction = 'send_and_redirect_to_invoice';
      send_json('booking_' + model_id); //the server renders a real HTTP redirect
      $('#screenwait').show();
      
    } else if (action == 'booking_invoice') {
      submit_json.jsaction = 'pay_and_redirect_to_invoice';
      send_json('booking_' + model_id); //the server renders a real HTTP redirect
      $('#screenwait').show();
      
    } else if (action == 'invoice_move') {
      $.ajax({
        type: 'post',
        url: '/route',
        data: {currentview:'invoice', jsaction:'move', target_table_id:options.target_table_id, id:model_id},
        timeout: 15000
      })
    }
    
  }
  emit('after.go_to.' + target, {model_id:model_id, action:action, options:options});
}

/* ======================================================*/
/* ============       DEBUG               ===============*/
/* ======================================================*/

function send_email(subject, message) {
  console.log('send_email:', subject, message);
  message += "\n\nuser login: " + user_login;
  message += "\n\n" + navigator["userAgent"];
  $.ajax({
    type: 'post',
    url:'/session/email',
    data: {s:subject, m:message}
  })
}

/* ======================================================*/
/* ============ JSON SENDING AND QUEUEING ===============*/
/* ======================================================*/

function send_json(object_id) {
  //submit_json_queue[object_id] = submit_json; // this would be  only  a pointer assignment, which is bad for quick UI operation. We need to do a deep object copy instead:
  submit_json_queue[object_id] = $.extend(true, {}, submit_json);
  if ( typeof submit_json_queue[object_id].sent_at == 'undefined' ) {
    submit_json_queue[object_id].sent_at = (new Date).getTime();
  }
  items_json_queue[object_id] = $.extend(true, {}, items_json);
  display_queue();
  submit_json.model = {};
  delete submit_json.items;
  // submit_json.currentview should be preserved
  // submit_json.target should be preserved
  items_json = {};
  send_queue(object_id);
}

function send_queue(object_id) {
  $.ajax({
    type: 'post',
    url: '/route',
    data: submit_json_queue[object_id],
    timeout: 40000,
    complete: function(data,status) {
      if (status == 'timeout') {
        send_email('send_queue: timeout for object_id ' + object_id, '');
        if (submit_json_queue[object_id]) {
          var tablename = "?";
          if (submit_json_queue[object_id].model && submit_json_queue[object_id].model.table_id ) {
            tablename = resources.tb[submit_json_queue[object_id].model.table_id].n;
          } else {
            send_email('send_queue: extreme load ' + object_id, 'submit_json_queue does contain object_id');
            // this happens only under extreme load of the JS UI and the server, tested by ichabod.
          }
          alert("Oops! Die Bestellung auf Tisch " + tablename + " wurde abgesendet, aber nach 40 Sekunden immer noch keine Antwort vom Server empfangen. Bitte die Bestellung manuell überprüfen.");
          clear_queue(object_id); // server probably has processed the request, so we are clearing the queue here, with the risk that the taken order may be lost. But this is better than having taken items twice.
          update_tables();
        } else {
          send_email('send_queue: extreme load ' + object_id, 'submit_json_queue does not contain object_id');
        }
      } else if (status == 'success') {
        if (submit_json_queue[object_id]) {
          table_id = submit_json_queue[object_id].model.table_id;
          if (offline_tables.hasOwnProperty(table_id)) {
            delete offline_tables[table_id];
            $('#table' + table_id).css('border', '1px solid gray');
            clear_queue(object_id);
            route('table', table_id);
            alert(i18n.successfully_sent);
          }
        } else {
          send_email('send_queue: success, but submit_json_queue empty for object_id ' + object_id, 'User probably has entered the table in offline mode.');
        }
        clear_queue(object_id);
        update_tables();
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            var answer = confirm(i18n.no_connection_retry);
            if (answer == true) {
              send_queue(object_id);
            } else {
              var table_id = submit_json_queue[object_id].model.table_id;
              $('#table' + table_id).css('border', '3px solid white');
              offline_tables[table_id] = true;
            }
            break;
          case 4:
            if (submit_json_queue[object_id]) {
              var tablename = resources.tb[submit_json_queue[object_id].model.table_id].n;
              send_email('send_queue: Server Error for object_id ' + object_id, '');
              alert("Oops! Bei der Verarbeitung der Bestellung von Tisch " + tablename + " ist ein Fehler auftegreten. Bitte Bestellung manuell überprüfen.");
              submit_json_queue[object_id].sent_at = (new Date).getTime() - 60000; // allow the user to view offline items immediately
            }
            break;
          default:
            send_email('send_queue: unknown ajax error readyState', '');
        }
      } else if (status == 'parsererror') {
        send_email('send_queue: parsererror');
        alert("Oops! Der Server hat die Bestellung erfolgreich verarbeitet, aber mit einem falschen Code geantwortet. Diesen Zwischenfall bitte dem Techniker melden.");
        clear_queue(object_id); // server has processed correctly but returned malformed JSON, so no resubmission.
      } else {
        send_email('send_queue: unknown ajax complete status', '');
      }
      audio_enabled = false; // skip one beep
      counter_update_item_lists = 2;
    }
  });
}

function clear_queue(i) {
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





/* ========================================================*/
/* ============ DYNAMIC RENDERING FROM JSON ===============*/
/* ========================================================*/

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

function scribe_image(object) {
  var path;
  if (object.h == true) {
    path = "<img src='/items/" + object.id + ".svg'>";
  } else {
    path = '';
  }
  return path;
}

/* ===================================================================*/
/* ======= RENDERING ARTICLES, QUANTITIES, ITEMS               =======*/
/* ===================================================================*/


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


function add_category_button(label,options) {
    var cat = $('<div id="'+options.id+'" class="category"></div>');
    var cat_label = '<div class="category_label"><span>'+label+'</span></div>';
    var styles = [];
    var bgcolor = "background-color: rgb(XXX);";
    var bgimage = "background-image: url('XXX');";
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
        $('#customers_list').remove('');
      } else {
        $('#customers_list').remove('');
      }
    });
  })();
  qcontainer.append(abutton);
  return qcontainer;
}

function search_customers() {
  var searchstring = $('#customer_search_input').val();
  if (searchstring.length > 2) {
    submit_json.model['customer_name'] = searchstring;
    var results = customer_search(searchstring);
    var qcont = $("#customers_list");
    $('.customer-entry').remove();
    for (var i in results) {
      qcont = add_customer_button(qcont,results[i],false);
    }
  }
}

function show_customers(append_to) {
  if ($('#customers_list').length == 1) {
    $('#customers_list').remove(); //this toggles
    return
  }
  $('#articles').html('');
  var qcontainer = $('<div id="customers_list"></div>');
  qcontainer.addClass('quantities');
  var search_box = $('<input id="customer_search_input" value="" />');
  search_box.on('keyup', search_customers);
  if (settings.workstation) {
    search_box.keyboard( {openOn: '', accepted: search_customers } );
    search_box.click(function(){
      search_box.getkeyboard().reveal();
    });
  }
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
  $.each(resources.c[cat_id].a, function(art_id,art_attr) {
    a_object = this;
    var abutton = create_dom_element('div',{id:"article"+art_id},art_attr.n,'#articles');
    abutton.addClass('article');
    //abutton.html(art_attr.n);
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
    //$('#articles').append(abutton);
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


function update_order_from_invoice_form(data, button) {
  data.currentview = 'invoice';
  data.payment_method_items = submit_json.payment_method_items;
  if (! $.isEmptyObject(submit_json.split_items_hash[data.id])) {
    data.split_items_hash = submit_json.split_items_hash[data.id];
  }
  $.ajax({
    type: 'post',
    url: '/route',
    data: data,
    timeout: 60000
  });
  var loader = create_dom_element('img', {src:'/images/ajax-loader2.gif'}, '');
  loader.css('margin', '7px');
  loader.css('position','absolute');
  
  if (typeof button !== 'undefined') {
    $(button).append(loader);
    $(button).css('opacity','0.5');
  } else {
    if ( data.jsaction == 'change_cost_center' || data.jsaction == 'mass_assign_tax' ) {
      $('#model_' + data.id + ' a.iconbutton').append(loader);
      $('#model_' + data.id + ' a.iconbutton').css('opacity','0.5');
      $('#model_' + data.id + ' a.iconbutton').attr('onclick', ''); // this prevents timing problems with multiple passenger instances when cost center is changed and the order finished within a fraction of a second. the user has to wait until the server re-renders the DOM.
    }
  }
  
  if ($.isEmptyObject(submit_json.split_items_hash[data.id]) && ( data.jsaction != 'change_cost_center' && data.jsaction != 'mass_assign_tax') ) {
    if ($('div.invoice:visible').length == 1) {
      route('tables');
    } else {
      // stay on invoice page but remove the current invoice from DOM
      $('#model_' + data.id).hide();
      delete submit_json.split_items_hash[data.id];
    }
  }
  invoice_update = true; // if any of the print or finish buttons is pressed, always let the server response update the invoices. splitting an item can interrupt this.
}

function update_order_from_refund_form(data) {
  data['currentview'] = 'refund';
  $.ajax({
    type: 'post',
    url: '/route',
    data: data,
    timeout: 20000
  });
}

function rotate_tax_item(id) {
  $.ajax({
    type: 'put',
    url: '/items/rotate_tax',
    data: {id:id},
    timeout: 20000
  });
}

function split_item(id, order_id, sum, partner_item_id, increment) {
  //invoice_update = false; // in case the user splits the invoice, a pending response from the server should not re-render the invoices and therefore overwrite the users input. this is a global variable and will be checked in orders/render_invoice_form.js.erb
  
  var partner_mode = $('div.invoice:visible').length == 2;
  
  if (order_id == submit_json.split_items_hash.original) {
    var ooid = submit_json.split_items_hash.original;
    var poid = submit_json.split_items_hash.partner;
  } else {
    var ooid = submit_json.split_items_hash.partner;
    var poid = submit_json.split_items_hash.original;
  }
  var oiid = id; // original item id
  var piid = partner_item_id;
  
  var item_count_td = $('#' + ooid + '_' + oiid + '_count');
  var item_count_split_td = $('#' + ooid + '_' + oiid + '_count_split');
  var original_count = item_count_td.html() == '' ? 0 : parseInt(item_count_td.html());
  var split_count = item_count_split_td.html() == '' ? 0 : parseInt(item_count_split_td.html());

  if (((increment == 1) && (original_count > 0) || (increment == -1) && (split_count > 0))) {
    if (submit_json.split_items_hash[ooid].hasOwnProperty(oiid)) {
      submit_json.split_items_hash[ooid][oiid].split_count += increment;
      submit_json.split_items_hash[ooid][oiid].sum = submit_json.split_items_hash[ooid][oiid].split_count * sum;
    } else {
      submit_json.split_items_hash[ooid][oiid] = {};
      submit_json.split_items_hash[ooid][oiid].split_count = 1;
      submit_json.split_items_hash[ooid][oiid].original_count = original_count;
      submit_json.split_items_hash[ooid][oiid].sum = sum;
    }
    original_count -= increment;
    split_count += increment;
    item_count_td.html(original_count == 0 ? '' : original_count);
    item_count_split_td.html(split_count == 0 ? '' : split_count);
    
    // update totals
    var subtotal_span_original = $('#subtotal_' + ooid);
    var subtotal_span_split_original = $('#subtotal_split_' + ooid);
    var split_subtotal_original = 0;
    $.each(submit_json.split_items_hash[ooid], function(k,v) {
      split_subtotal_original += v.sum;
    })
    var subtotal_span_partner = $('#subtotal_' + poid);
    var subtotal_span_split_partner = $('#subtotal_split_' + poid);
    var split_subtotal_partner = 0;
    if (partner_mode) {
      $.each(submit_json.split_items_hash[poid], function(k,v) {
        split_subtotal_partner += v.sum;
      })
    }

    var total_all_models = 0
    $.each(submit_json.totals, function(k,v) {
      total_all_models += v.model_original;
    })

    var subtotal_original = submit_json.totals[ooid].model_original - split_subtotal_original + split_subtotal_partner;
    submit_json.totals[ooid].model = subtotal_original;
    subtotal_span_original.html(number_to_currency(subtotal_original));
    subtotal_span_split_original.html(number_to_currency(split_subtotal_original));
    
    if (partner_mode) {
      var subtotal_partner = submit_json.totals[poid].model_original - split_subtotal_partner + split_subtotal_original;
      submit_json.totals[poid].model = subtotal_partner;
      subtotal_span_partner.html(number_to_currency(subtotal_partner));
      subtotal_span_split_partner.html(number_to_currency(split_subtotal_partner));
    }
    
    // update payment methods
    var payment_method_inputs_original = $('#payment_methods_container_' + ooid + ' td.payment_method_input input');
    var payment_method_input_original = payment_method_inputs_original[payment_method_inputs_original.length - 1];
    $(payment_method_input_original).val(subtotal_original.toFixed(2));
    var pmid = $(payment_method_input_original).attr('pmid');
    payment_method_input_change(payment_method_input_original, pmid, ooid)
    
    if (partner_mode) {
      var payment_method_inputs_partner = $('#payment_methods_container_' + poid + ' td.payment_method_input input');
      var payment_method_input_partner = payment_method_inputs_partner[payment_method_inputs_partner.length - 1];
      $(payment_method_input_partner).val(subtotal_partner.toFixed(2));
      var pmid = $(payment_method_input_partner).attr('pmid');
      payment_method_input_change(payment_method_input_partner, pmid, poid)
    }
  }
}

function submit_split_items(order_id) {
  if (! $.isEmptyObject(submit_json.split_items_hash[order_id])) {
    var splitbutton = $('#model_' + order_id + ' a.splitinvoice_button');
    var loader = create_dom_element('img', {src:'/images/ajax-loader2.gif'}, '', splitbutton);
    loader.css('margin', '7px');
    splitbutton.css('opacity','0.5');

    $.ajax({
      type: 'put',
      url: '/items/split',
      data: {jsaction:'split',split_items_hash:submit_json.split_items_hash[order_id],order_id:order_id},
      timeout: 90000,
      complete: function(data,status) {
        if (status == 'timeout') {
          alert("Der Server hat nach dem Splitten 90 Sekunden lang nicht geantwortet. Bitte zur Überprüfung auf den Bestellbildschirm wecheln und Rechnungsansicht nochmals aufrufen.");
        }
      }
    });
    submit_json.split_items_hash = {}; // prevent from double clicking the button
    invoice_update = true; // when pressing the split button, let the server repsonse refresh the invoice view. grep for invoice_update = false; where the server should not destroy the DOM.
  }
}

// This is only called from the rooms view. For historical reasons, the order invoice view has the ocntainers hardcoded.
function show_payment_method_items(model_id,allow_delete) {
  var pm_container = $('#payment_methods_container_' + model_id);
  pm_container.attr('style', 'overflow: visible;');
  pm_container.show();
  if ($.isEmptyObject(submit_json.payment_method_items[model_id]) == true) add_payment_method(model_id, null, submit_json.totals[model_id].model + submit_json.totals[model_id].booking_orders);
  if (allow_delete) deletable(pm_container);
}

function add_payment_method(model_id,id,amount) {
  payment_method_uid += 1;
  var pm_container = $('#payment_methods_container_' + model_id);
  var pm_table = $('#payment_methods_container_' + model_id + ' table');
  
  pm_row = $(document.createElement('tr'));
  pm_row.addClass('payment_method_row');
  pm_row.attr('id', 'payment_method_row' + payment_method_uid);
  submit_json.payment_method_items[model_id][payment_method_uid] = {id:null, amount:0};
  var j = 0;
  $.each(resources.pm, function(k,v) {
    if (v.chg) {
      //do not display the change money paymet method
      return true
    }
    j += 1;
    pm_button = $(document.createElement('td'));
    pm_button.addClass('payment_method');
    pm_button.html(v.n);
    if ( !id && j == 1 ) {
      submit_json.payment_method_items[model_id][payment_method_uid].id = v.id;
      pm_button.addClass('selected');
    } else if (id == v.id) {
      submit_json.payment_method_items[model_id][payment_method_uid].id = v.id;
      pm_button.addClass('selected');
    }
    (function() {
      var uid = payment_method_uid;
      pm_button.on('click', function() {
        submit_json.payment_method_items[model_id][uid].id = v.id;
        $('#payment_method_row' + uid + ' td').removeClass('selected');
        $(this).addClass('selected');
        $('#payment_method_' + uid + '_amount').select();
        if(settings.workstation) {
          $('#payment_method_'+ uid + '_amount').select();
        }
      });
    })();
    pm_row.append(pm_button);
  });
  pm_input = $(document.createElement('input'));
  pm_input.attr('type', 'text');
  pm_input.attr('pmid', payment_method_uid);
  pm_input.attr('id', 'payment_method_' + payment_method_uid + '_amount');
  if (amount) {
    pm_input.val(number_with_precision(amount,2));
    submit_json.payment_method_items[model_id][payment_method_uid].amount = amount;
  } else {
    if (submit_json.totals[model_id].hasOwnProperty('booking_orders')) {
      booking_order_total  = submit_json.totals[model_id].booking_orders;
    } else {
      booking_order_total = 0;
    }
    pm_input.val(number_with_precision(submit_json.totals[model_id].model + booking_order_total - submit_json.totals[model_id].payment_method_items, 2));
  }
  submit_json.payment_method_items[model_id][payment_method_uid]._delete = false;
  payment_method_input_change(pm_input, payment_method_uid, model_id)
  if (settings.workstation) {
    (function(){
      var uid = payment_method_uid;
      var element = pm_input;
      element.keyboard({
        openOn: 'click',
        accepted: function(){ 
          payment_method_input_change(element, uid, model_id)
        },
        layout:'num'
      });
    })()
  }
  (function() {
    var uid = payment_method_uid;
    var mid = model_id;
    pm_input.on('keyup', function(){
      payment_method_input_change(this, uid,mid);
    });
  })();
  pm_input_cell = $(document.createElement('td'));
  pm_input_cell.addClass('payment_method_input');
  pm_input_cell.append(pm_input);
  pm_row.append(pm_input_cell);
  
  pm_table.append(pm_row);
  
  if ($('.booking_form').is(":visible")) {
    deletable(pm_row,'append',function () {
      submit_json.payment_method_items[model_id][payment_method_uid]._delete = true;
      payment_method_input_change(pm_input, payment_method_uid, model_id)
      $(this).parent().remove();
    });
  }
  $('#payment_methods_container_' + model_id + ' table').prepend(pm_row);
  $('#payment_method_'+ payment_method_uid + '_amount').select();
}

function payment_method_input_change(element, uid, mid) {
  amount = $(element).val();
  amount = amount.replace(',','.');
  if (amount == '') { amount = 0; }
  submit_json.payment_method_items[mid][uid].amount = parseFloat(amount);
  payment_method_total = 0;
  $.each(submit_json.payment_method_items[mid], function(k,v) {
    if (v._delete == false) payment_method_total += v.amount;
  });
  submit_json.totals[mid].payment_method_items = payment_method_total;
  if (submit_json.totals[mid].hasOwnProperty('booking_orders')) {
    booking_order_total  = submit_json.totals[mid].booking_orders;
  } else {
    booking_order_total = 0;
  }
  change = - number_with_precision(submit_json.totals[mid].model + booking_order_total - payment_method_total, 2);
  $('#change_' + mid).html(number_to_currency(change));
  if (change < 0) {
    $('#change_' + mid).css("color", "red");
  } else if (change == 0) {
    if ($('.booking_form').is(":visible")) {
      $('#change_' + mid).css("color", "white");
    } else {
      $('#change_' + mid).css("color", "black");
    }
  } else {
    $('#change_' + mid).css("color", "green");
  }
}



function remove_payment_method_by_name(name) {
  if (!submit_json.payment_method_items)
    return;
  npms = [];
  for (var i in submit_json.payment_method_items) {
    if (!submit_json.payment_method_items[i].name == name) {
      npms.push(submit_json.payment_method_items[i]);
    }
  }
  submit_json.payment_method_items = npms;
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

function item_changeable(d) {
  var start_count = items_json[d].sc;
  var count = items_json[d].c;
  return ( (typeof(start_count) == 'undefined') || count > start_count )
}

function permit_select_open(d) {
  if ( item_changeable(d) ) {
    $('#options_select_' + d).attr('disabled',false);
  } else {
    $('#options_select_' + d).attr('disabled',true);
  }
}

function clone_item(d) {
  if (items_json[d].c > 1 && permissions.add_option_to_sent_item == false) {
    var clone_d = add_new_item(items_json[d], true, d);
    decrement_item(d);
    d = clone_d;
  }
  return d
}

function add_option_to_item(d, value, cat_id) {
  if (value == 0) {
    // clear all options
    set_json('order', d, 'i', [0]);
    set_json('order', d, 't', {});
    $('#optionsnames_' + d).html('');
  } else {
    $('#options_select_' + d).val(''); //needed for mobile phones to be able to choose the same option seveal times
    d = clone_item(d);
    var optionobject = resources.c[cat_id].o[value];
    var option_uid = (new Date).getTime();
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

function toggle_order_booking () {
  if (submit_json.currentview == 'rooms') {
    route('tables');
  } else {
    route('rooms');
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
  if (options == null) return;
  if (permissions.add_option_to_sent_item == false) {
    var clearbutton = create_dom_element('span',{},'&nbsp;✗&nbsp;','#options_div_' + d);
    clearbutton.addClass('option');
    clearbutton.on('click', function() {
      add_option_to_item(d, 0, cat_id);
    })
  }
  jQuery.each(options, function(key,object) {
    button = $(document.createElement('span'));
    button.html(object.n);
    button.addClass('option');
    (function() {
      var cid = cat_id;
      var o = object;
      button.on('click',function(){
        $(this).effect('highlight');
        add_option_to_item(d, o.s + '_' + o.id, cid);
      });
    })();
    $('#options_div_' + d).append(button);
  });
}

function open_options_div(d) {
  if (item_changeable(d) || permissions.add_option_to_sent_item) {
    d = clone_item(d);
    if (settings.mobile) {
      $('#options_div_'+d).show();
    } else {
      $('#options_div_'+d).slideDown();
    }
  }
}

function close_options_div(d) {
  if (settings.mobile) {
    $('#options_div_'+d).hide();
  } else {
    $('#options_div_'+d).slideUp();
  }
}

function open_table_div() {
  if (settings.mobile) {
    $('#tablesselect').show();
  } else {
    $('#tablesselect').slideDown();
  }
}

function close_table_div() {
  if (settings.mobile) {
    $('#tablesselect').hide();
  } else {
    $('#tablesselect').slideUp();
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

function compose_optionnames(object){
  names = '';
  jQuery.each(object.t, function(k,v) {
    names += (v.n + '<br>')
  });
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

function get_table_show(table_id) {
  $.ajax({
    type: 'GET',
    url: '/tables/' + table_id,
    timeout: 20000,
    complete: function(data,status) {
      if (status == 'timeout') {
        //debug('get_table_show: TIMEOUT');
        if ( get_table_show_retry ) {
          window.setTimeout(function() {
            get_table_show(table_id)
          }, 1000);
        }
      } else if (status == 'success') {
        //debug('get_table_show: success');
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            //debug('get_table_show: No network connection. get_table_show is ' + get_table_show_retry);
            if ( get_table_show_retry ) {
              window.setTimeout(function() {
                get_table_show(table_id)
              }, 5000);
            }
            break;
          case 4:
            //debug('get_table_show: ' + parse_rails_error_message(data.responseText));
            break;
        }
      } else if (status == 'parsererror') {
        //debug('get_table_show: parser error: ' + data);
      } else {
        //debug('get_table_show: unsupported status');
      }
    }
  }); //the JS response repopulates items_json and renders items_json
}

function update_tables(){
  $.ajax({
    url: '/tables',
    dataType: 'json',
    timeout: 15000,
    success: function(data) {
      resources.tb = data;
      render_tables();
    }
  });
}

function update_resources(mode) {
  $.ajax({
    url: '/vendors/render_resources',
    dataType: 'script',
    complete: function(data,state) {
      update_resources_success(data)
    },
    timeout: 15000,
    success: function() {
      if (mode == 'documentready') {
        update_tables();
        if ( ! $.isEmptyObject(resources.sn) ) {
          render_season_illustration();
        }
        //automatically route to views depending on uri parameters
        var uri_attrs = uri_attributes();
        if (uri_attrs.rooms == '1') {
          setTimeout(function(){
            route('rooms')
          }, 2000);
        }
        if (uri_attrs.booking_id != undefined) {
          setTimeout(function(){
            route('booking', uri_attrs.booking_id);
          }, 2000);
        }
        if (uri_attrs.table_id != undefined) route('table', uri_attrs.table_id);
        if (uri_attrs.report == '1') report.functions.display_popup();
        if (customer != null) route('table', customer.table_id);
      }
    }
  });
}

function update_resources_success(data) {
  emit('ajax.update_resources.success', data);
}


function update_item_lists() {
  if (permissions.see_item_notifications_vendor_preparation || permissions.see_item_notifications_vendor_delivery) {
    // permitting any of the vendor notification overrides all of the user notifications
    $.ajax({
      url: '/items/list',
      dataType: 'json',
      data: {type:'vendor'},
      success: function(data) {
        resources.notifications_vendor = data;
        notification_alerts('vendor');
        if (permissions.see_item_notifications_vendor_preparation) render_item_list('interactive', 'vendor', 'preparation');
        if (permissions.see_item_notifications_vendor_delivery)    render_item_list('interactive', 'vendor', 'delivery');
        if (settings.workstation && permissions.see_item_notifications_static) {
          if (permissions.confirmation_user) render_item_list('static', 'vendor', 'confirmation');
          if (permissions.see_item_notifications_vendor_preparation) render_item_list('static', 'vendor', 'preparation');
          if (permissions.see_item_notifications_vendor_delivery) render_item_list('static', 'vendor', 'delivery');
        }
      },
      timeout: 15000 
    });
  } else if (permissions.see_item_notifications_user_preparation || permissions.see_item_notifications_user_delivery) {
    $.ajax({
      url: '/items/list',
      dataType: 'json',
      data: {type:'user'},
      success: function(data) {
        resources.notifications_user = data;
        notification_alerts('user');
        if (permissions.see_item_notifications_user_preparation) render_item_list('interactive', 'user', 'preparation');
        if (permissions.see_item_notifications_user_delivery)    render_item_list('interactive', 'user', 'delivery');
        if (settings.workstation && permissions.see_item_notifications_static) {
          if (permissions.confirmation_user) render_item_list('static', 'user', 'confirmation');
          if (permissions.see_item_notifications_user_preparation) render_item_list('static', 'user', 'preparation');
          if (permissions.see_item_notifications_user_delivery) render_item_list('static', 'user', 'delivery');
        }
      },
      timeout: 15000 
    });
  }
}

function notification_alerts(model) {    
  if (model == 'user') {
    var delivery_notification_user_count = Object.keys(resources.notifications_user.delivery).length;
    var prepraration_notification_user_count = Object.keys(resources.notifications_user.preparation).length;
    var total_count = delivery_notification_user_count + prepraration_notification_user_count;
  } else if (model == 'vendor') {
    var delivery_notification_vendor_count = Object.keys(resources.notifications_vendor.delivery).length;
    var prepraration_notification_vendor_count = Object.keys(resources.notifications_vendor.preparation).length;
    var total_count = delivery_notification_vendor_count + prepraration_notification_vendor_count;
  }
  if (total_count > 0) {
    $('.items_notifications_button').html(total_count);
    $('#mobile_last_invoices_button').html(total_count);
    if (permissions.audio && audio_enabled) {
      alert_audio();
    }
    audio_enabled = true;
  }
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
  if(_get('customers.button_added')) return
  if(!permissions.manage_customers) return
  opts = {id:'customers_category_button', handlers:{'mousedown':function(){show_customers('#articles')}}, bgcolor:"50,50,50", bgimage:'/assets/category_customer.png', append_to:'#categories'};
  add_category_button(i18n.customers, opts);
  _set('customers.button_added',true);
}

function highlight_button(element) {
  //$(element).effect("highlight", {}, 300); // this is CPU intensive for some mobile devices and has been disabled.
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
  $("#" + id).keyboard({ 
    openOn: 'focus',
    layout: 'num',
    accepted: function(){ 
      $.ajax({
        url: "/orders/update?currentview=update_pm&pid=" +pmid+ "&amount=" + $("#" + id).val(), 
        type: 'PUT'
      }); 
    }
  });
}


function render_item_list(type, model, scope) {
  if (type == 'interactive') {
    var list_container = $('#list_interactive_' + scope);
    list_container.html('');
    $.each(resources['notifications_' + model][scope], function(k,v) {
      
      var table_name = resources.tb[v.tid].n;
      var user_id = v[scope + '_uid'];
      if (user_id != null) {
        var user_name = resources.u[user_id].n;
      }
      
      var item_container = create_dom_element('div',{id:'item_list_' + scope + '_'+ v.id},'',list_container);
      item_container.addClass('item_list');
      var hours = v.t.substring(0,2);
      var minutes = v.t.substring(3,5);
      var seconds = v.t.substring(6,8);

      var t1 = new Date();
      t1.setHours(hours);
      t1.setMinutes(minutes);
      t1.setSeconds(seconds);

      var t2 = new Date();
      var difference = t2-t1;
      var color_intensity = Math.floor(difference/upper_delivery_time_limit * 255);
      color_intensity += 1;
      color_intensity = (color_intensity < 0) ? 255 : color_intensity;
      var color = 'rgb(' + color_intensity + ', 60, 60)';
      var waiting_time = Math.floor(difference/60000);
      var confirmed = v[scope + '_c'] != null
      if (!confirmed) {
        var unconfirmed_element = create_dom_element('div',{id:'item_list_'+scope+'_'+v.id+'_unconfirmed'}, table_name + ' | ' + v.c + " × " + v.l, item_container);
        unconfirmed_element.css('background-color', color);
        unconfirmed_element.addClass('unconfirmed');
        unconfirmed_element.on('click', function() {
          item_list_confirm(v.id, model, scope)
        });
      }
      var confirmed_element = create_dom_element('div',{id:'item_list_'+scope+'_'+v.id+'_confirmed', style:'display: none;'}, '', item_container);
      confirmed_element.addClass('confirmed');
      confirmed_element.css('background-color', color);
      if (confirmed) confirmed_element.show();
      if (v.s) var image = create_dom_element('img',{src:'/items/' + v.id +'.svg'},'',confirmed_element);
      var table = create_dom_element('table',{},'',confirmed_element);
      var row = create_dom_element('tr',{},'',table);
      var cell_tablename = create_dom_element('td',{},table_name,row);

      switch(scope) {
        case 'confirmation':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          break;
        case 'preparation':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          var cell_reference_count_2 = create_dom_element('td', {}, v.confirmation_c, row);
          cell_reference_count_2.addClass('reference_count');
          break;
        case 'delivery':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          var cell_reference_count_2 = create_dom_element('td', {}, v.confirmation_c, row);
          cell_reference_count_2.addClass('reference_count');
          var cell_reference_count_3 = create_dom_element('td', {}, v.preparation_c, row);
          cell_reference_count_3.addClass('reference_count');
          break;
      }
     
      
      var cell_increment_count = create_dom_element('td',{id:'item_list_' + scope +'_'+ v.id + '_increment_button'}, v[scope + '_c'], row);
      cell_increment_count.addClass('increment');
      cell_increment_count.on('click', function() {
        item_list_increment(v.id, model, scope);
      });
      var cell_reset = create_dom_element('td',{id:'item_list_' + scope +'_' + v.id + '_reset_button'}, v.l, row);
      cell_reset.addClass('update');
    })
  } else if (type == 'static') {
    var list_container = $('#list_static_' + scope);
    list_container.html('');
    $.each(resources['notifications_' + model][scope], function(k,v) {
      var table_name = resources.tb[v.tid].n;
      var user_id = v[scope + '_uid'];
      if (user_id != null) {
        var user_name = resources.u[user_id].n;
      }
      
      var hours = v.t.substring(0,2);
      var minutes = v.t.substring(3,5);
      var seconds = v.t.substring(6,8);

      var t1 = new Date();
      t1.setHours(hours);
      t1.setMinutes(minutes);
      t1.setSeconds(seconds);

      var t2 = new Date();
      var difference = t2-t1;
      var color_intensity = Math.floor(difference/upper_delivery_time_limit * 255);
      color_intensity += 1;
      color_intensity = (color_intensity < 0) ? 255 : color_intensity;
      var color = 'rgb(' + color_intensity + ', 60, 60)';
      var waiting_time = Math.floor(difference/60000);
      var waiting_time_label = (waiting_time > 0) ? waiting_time + 'min.<br/>' : '';

      switch(scope) {
        case 'confirmation':
          var count = v.c - v.confirmation_c;
          break;
        case 'preparation':
          var count = v.confirmation_c - v.preparation_c;
          break;
        case 'delivery':
          var count = v.preparation_c - v.delivery_c;
          break;
      }
      if (count != null) {
        var label = table_name + " | " + waiting_time_label + count + ' × ' + v.l;
        var item_container = create_dom_element('div',{id:'item_list_' + scope + '_' +  v.id}, label, list_container);
        item_container.css('background-color', color);
        item_container.addClass('item_list');
      }
    })
  }
}

function item_list_confirm(id, model, scope) {
  var unconfirmed_element = $('#item_list_' + scope + '_' + id + '_unconfirmed');
  var confirmed_element = $('#item_list_' + scope + '_' + id + '_confirmed');
  var scope_count_attribute = (scope == 'preparation') ? 'preparation_c' : 'delivery_c'
  unconfirmed_element.remove();
  resources['notifications_' + model][scope][id][scope_count_attribute] = 0;
  $('#item_list_' + scope + '_' + id + '_increment_button').html(0);
  confirmed_element.show();
  $.ajax({
    method: 'post',
    data: {id:id, attribute:scope+'_count', value:0},
    url: '/items/set_attribute'
  })
}


function item_list_increment(id, model, scope) {
  var increment_button = $('#item_list_' + scope + '_' + id + '_increment_button');
  
  var scope_count_attribute = null;
  switch(scope) {
    case 'confirmation':
      var reference_count_attribute = 'c';
      var scope_count_attribute = 'confirmation_c'
      break;
    case 'preparation':
      var reference_count_attribute = 'confirmation_c';
      var scope_count_attribute = 'preparation_c'
      break;
    case 'delivery':
      var reference_count_attribute = 'preparation_c';
      var scope_count_attribute = 'delivery_c'
      break;
  }
  
  var c = resources['notifications_' + model][scope][id][scope_count_attribute];
  var r = resources['notifications_' + model][scope][id][reference_count_attribute];
  
  if ( c < r ) {
    increment_button.html(c + 1);
    resources['notifications_' + model][scope][id][scope_count_attribute] = c+1;
    increment_button.css('background-color','#3a474d');
    $.ajax({
      method: 'post',
      url: '/items/set_attribute',
      data: {id:id, attribute:scope+'_count', value:c+1},
      success: function() {
        increment_button.css('background-color','#3a4d3a');
        //increment_button.effect('highlight');
        counter_update_item_lists = 4;
        audio_enabled = false; // skip one beep
      },
      error: function() {
        increment_button.css('background-color','#74101B');
      }
    });
  }
}

function item_list_reset(id, scope) {
  var increment_button = $('#item_list_' + scope + '_' + id + '_increment_button');
  var scope_count_attribute = (scope == 'preparation') ? 'preparation_c' : 'delivery_c';
  increment_button.html(0);
  $.ajax({
    method: 'post',
    url: '/items/set_attribute',
    data: {id:id, attribute:scope+'_count', value:0},
    success: function() {
      increment_button.css('background-color','#3a4d3a');
      //increment_button.effect('highlight');
      counter_update_item_lists = 3;
    },
    error: function() {
      increment_button.css('background-color','#74101B');
    }
  })
}

function render_tables() {
  $('#tables').html('');
  $('#tablesselect_container').html('');
  $.each(resources.tb, function(k,v) {
    // determine color
    var bgcolor = null;
    if (v.auid) bgcolor = resources.u[v.auid].c;
    if (!v.e) bgcolor = 'black';
   
    //--------------------------
    // render spans for the move function
    var move_table_span = create_dom_element('span', {}, v.n, '#tablesselect_container');
    move_table_span.on('click', function() {
      route('tables', submit_json.model.table_id, 'move', {target_table_id:v.id});
    })
    move_table_span.addClass('option');
    if (typeof(bgcolor) == 'string') move_table_span.css('background-color', bgcolor);
    
    
    // ------------------------
    // render divs for the actual tables
    var mobile_mode = settings.mobile || settings.mobile_drag_and_drop;
    var left = mobile_mode ? v.lm : v.l;
    var top = mobile_mode  ? v.tm : v.t;
    var width = mobile_mode ? v.wm : v.w;
    var height = mobile_mode ? v.hm : v.h;
    if (v.r) {
      var tmp = width;
      width = height;
      height = tmp;
    }
         
    var statusclass = v.auid ? 'occupied' : 'vacant';
    var table = create_dom_element('div',{id:'table'+v.id,ontouchstart:'javascript:enable_audio();'}, v.n, '#tables');
    
    if (v.crid) {
      create_dom_element('span', {}, resources.customers.all[v.crid].n, table);
    } else if (v.auid) {
      create_dom_element('span', {}, resources.u[v.auid].n, table);
    }

    table.addClass(statusclass);
    table.addClass('table');
    table.css('left', left);
    table.css('top', top);
    table.css('width', width);
    table.css('height', height);
    if (offline_tables.hasOwnProperty(v.id)) {
      table.css('border', '3px solid white');
    }
    if (typeof(bgcolor) == 'string') table.css('background-color', bgcolor);

    if (v.cp) {
      // confirmation pending
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (v.rf) {
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('cash_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (v.rw) {
      // requested waiter
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('user_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (permissions.move_tables && settings.mobile_drag_and_drop || settings.admin_interface) {
      table.draggable({ stop: function() {
        update_table_coordinates(v.id)}
      })
      table.css('background-color', 'grey');      
    } else {
      if (v.e && !(!permissions.confirmation_user && (v.cp || v.rf || v.rw))) {
        // when confirmation_user is false, this user cannot view the order if any customer requests are pending
        _set('table',v,table);
        table.on('mousedown', function() {
          var v = _get('table',$(this));
          route('table',v.id);
        });
      }
    }
  });
}

function update_table_coordinates(id) {
  var table = $('#table' + id);
  var left = table.position().left;
  var top = table.position().top; 
  $.ajax({
    type: 'put',
    url: '/tables/' + id + '/update_coordinates',
    data: {left:left, top:top, mobile_drag_and_drop:settings.mobile_drag_and_drop},
    success: update_tables
  });
}

function switch_to_table() {
  $('#order_info').html(i18n.just_order);
  $('#order_note').val('');
  //$('#inputfields').html('');
  $('#itemstable').html('');
  $('#articles').html('');
  $('#quantities').html('');
  $('.target_table').val('');
  $('#spliced_seasons').hide();
  $('#items_notifications_interactive').hide();
  $('#items_notifications_static').hide();
  $('#functions_header_last_invoices').hide();
  $('#order_cancel_button').show();
  //---
  $('#orderform').show();
  $('#invoices').hide();
  $('#tables').hide();
  $('#areas').hide();
  $('#rooms').hide();
  $('.booking_form').remove();
  $('#functions_header_index').hide();
  $('#functions_header_invoice_form').hide();
  $('#functions_header_order_form').show();
  if (settings.mobile) { $('#functions_footer').show(); }
}


function parse_rails_error_message(raw_message) {
  var start1 = raw_message.indexOf('<pre>');
  var end1 = raw_message.indexOf('</pre>');
  var start2 = raw_message.indexOf('<pre><code>');
  var end2 = raw_message.indexOf('</code></pre>');
  var errormessage1 = raw_message.substring(start1,end1).replace(/<.*?>/g, '');
  var errormessage2 = raw_message.substring(start2,end2).replace(/<.*?>/g, '');
  return errormessage1 + "\n\n" + errormessage2;
}