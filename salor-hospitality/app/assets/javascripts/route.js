/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function route(target, model_id, action, options) {
  //debug("route(" + target + ", " + model_id + ", " + action + ", " + options + ")");
  //emit('before.go_to.' + target, {model_id:model_id, action:action, options:options});
  
  // ========== GO TO TABLES ===============
  if ( target == 'tables' ) {    
    submit_json.target = 'tables';
    get_table_show_retry = false;
    
    if (action == 'destroy') {
      submit_json.model.hidden = true;
      submit_json.jsaction = 'send';
      loadify_order_buttons();
      send_json('table_' + model_id, switch_to_tables);
      
    } else if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      loadify_order_buttons();
      send_json('table_' + model_id, switch_to_tables);

    } else if (action == 'move') {
      $(".tablesselect").slideUp();
      submit_json.jsaction = 'move';
      submit_json.target_table_id = options.target_table_id;
      send_json('table_' + model_id);
      switch_to_tables();
      
    } else if (action == 'send_and_finish_noinvoice') {
      submit_json.jsaction = 'send';
      submit_json.target = 'tables_no_invoice_print';
      loadify_order_buttons();
      send_json('table_' + model_id, switch_to_tables);
      
    } else if (action == 'send_and_finish_invoice') {
      submit_json.jsaction = 'send';
      submit_json.target = 'tables_do_invoice_print';
      loadify_order_buttons();
      send_json('table_' + model_id, switch_to_tables);

    } else {
      unloadify_order_buttons();
      items_json = {};
      switch_to_tables();
    }
    submit_json = {model:{}};
    submit_json.currentview = 'tables';


  // ========== GO TO TABLE ===============
  } else if ( target == 'table') {
    loadify_order_buttons();
    
    if (action == 'send') {
      // finish order
      submit_json.jsaction = 'send';
      submit_json.target = 'table_no_invoice_print';
      submit_json.model.note = $('#order_note').val();
      switch_to_table();
      send_json('table_' + model_id);
      // stay on table
      submit_json.model.table_id = model_id; // this is neccessary because send_json will clear the submit_json.model. since we stay on the table, we need to re-set the table_id.
      //final rendering will be done in application#route
      
    } else if (action == 'send_and_print' ) {
      // finish and print order receipt
      submit_json.jsaction = 'send';
      submit_json.target = 'table_do_invoice_print';
      submit_json.model.note = $('#order_note').val();
      switch_to_table();
      send_json('table_' + model_id);
      submit_json.model.table_id = model_id; // this is neccessary because send_json will clear the submit_json.model. since we stay on the table, we need to re-set the table_id.
      //final rendering will be done in application#route
      
    } else if (action == 'customer_request_send') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_send';
      var answer = confirm("Are you sure that you want to place this order?");
      switch_to_table();
      if (answer == true) {
        //alert(i18n.order_will_be_confirmed);
        send_json('table_' + model_id, function() {
          // logging out is rendered from application controller
        });
      } else {
        render_items();
        return
      }
    } else if (action == 'customer_request_finish') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_finish';
      alert(i18n.finish_was_requested);
      switch_to_table();
      send_json('table_' + model_id, function() {
        render_items()
      });
    } else if (action == 'customer_request_waiter') {
      submit_json.jsaction = 'send';
      submit_json.target = 'table_request_waiter';
      alert(i18n.waiter_was_requested);
      switch_to_table();
      send_json('table_' + model_id, function() {
        render_items()
      });
      
    } else if (false && submit_json_queue.hasOwnProperty('table_' + model_id)) {
      // no offline items are allowed in the latest version. disabled.
      
      // there are offline orders in the queue. display them instead of loading from the browser
      submit_json = $.extend(true, {}, submit_json_queue['table_' + model_id]); // deep copy
      items_json = $.extend(true, {}, items_json_queue['table_' + model_id]); // deep copy
      delete submit_json_queue['table_' + model_id];
      delete items_json_queue['table_' + model_id];
      render_items();
      //$('#order_cancel_button').hide();
      if (((new Date).getTime()) - submit_json.sent_at > 5000) {
        // the order could still be processed by the server. do not warn the user about offline items within a certain time period.
        send_email('route(): User has been informed about offline items', '');
        setTimeout(function() {
          alert(i18n.table_contains_offline_items);
        }, 500);
        //get_table_show(model_id);
      }
      
    } else if (action == 'specific_order') {
      switch_to_table();
      $.ajax({
        type: 'GET',
        url: '/tables/' + model_id,
        data: {order_id: options.order_id},
        timeout: 15000,
        cache: false,
        success: function() {
          unloadify_order_buttons();
          render_items();
        }
      }); //this just fetches items_json and a few other state variables
      
    } else if (action == 'from_booking') {
      switch_to_table();
      submit_json.jsaction = 'send_and_go_to_table';
      send_json('booking_' + options.booking_id);
      submit_json.model.table_id = model_id;
      
    } else {
      // regular click on a table from main view
      switch_to_table();
      get_table_show(model_id);
      if (settings.workstation) $("#sku_input").focus();
    }
    
    // clean workspace up
    submit_json = {model:{}};
    submit_json.model.table_id = model_id;
    submit_json.currentview = 'table';

  // ========== GO TO INVOICE ===============
  } else if ( target == 'invoice') {
    submit_json.target = 'invoice';
    invoice_update = true;
    interim_receipt_enabled = false;
    if (action == 'send') {
      submit_json.jsaction = 'send';
      submit_json.model.note = $('#order_note').val();
      loadify_order_buttons();
      send_json('table_' + model_id, switch_to_invoice);
      // invoice form will be rendered by the server as .js.erb template. see application#route
    } else {
      switch_to_invoice();
    }
    counter_update_tables = -1;
    screenlock_counter = -1;
    advertising_counter = -1;
    $('#invoices').html('');
    submit_json = {model:{},split_items_hash:{},totals:{},payment_method_items:{}};
    submit_json.currentview = 'invoice';

  // ========== GO TO ROOMS ===============
  } else if ( target == 'rooms' ) {
    if ((navigator.userAgent.indexOf('Chrom') == -1 &&
      navigator.userAgent.indexOf('WebKit') == -1) &&
      typeof(i18n) != 'undefined') {
      //$('#main').html('');
      //create_dom_element('div',{id:'message'}, i18n.browser_warning, '#main');
      alert(i18n.browser_warning);
      route("tables");
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
    advertising_counter = settings.advertising_timeout;
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
    $('#main').show();
    $('#spliced_seasons').show();
    $('#functions_header_index').hide();
    $('#functions_header_order_form').hide();
    //$('#items_notifications_interactive').hide();
    $('#items_notifications_static').hide();
    screenlock_counter = -1;
    advertising_counter = -1;
    submit_json = {currentview:'room', model:{room_id:model_id, room_type_id:null, duration:1}, items:{}};
    surcharge_headers = {guest_type_set:[], guest_type_null:[]};
    _set('surcharge_headers', surcharge_headers);
    items_json = {};
    $.ajax({
      type: 'GET',
      url: '/rooms/' + model_id,
      cache: false,
      timeout: 15000
    }); //this repopulates items_json and renders items
    window.display_booking_form(model_id);

  // ========== EXISTING BOOKING ===============
  } else if (target == 'booking') {
    scroll_to($('#container'),20);
    $('#rooms').hide();
    $('#areas').hide();
    $('#tables').hide();
    $('#rooms').hide();
    //$('.booking_form').remove();
    $('#main').show();
    $('#orderform').hide();
    $('#invoices').hide();
    $('#spliced_seasons').show();
    
    $('#functions_header_index').hide();
    $('#functions_header_order_form').hide();
    //$('#items_notifications_interactive').hide();
    $('#items_notifications_static').hide();
    
    screenlock_counter = -1;
    advertising_counter = -1;
    
    if (typeof(options) == 'undefined') {
      room_id = null;
    } else {
      room_id = options.room_id;
    }
    submit_json = {currentview:'room', model:{room_id:room_id, room_type_id:null, duration:1}, items:{}};
    surcharge_headers = {guest_type_set:[], guest_type_null:[]};
    _set('surcharge_headers', surcharge_headers);
    items_json = {};
    $.ajax({
      type: 'GET',
      url: '/bookings/' + model_id,
      cache: false,
      timeout: 15000
    });
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
        type: 'GET',
        url: '/route',
        cache: false,
        data: {
          currentview: 'invoice',
          jsaction: 'move',
          target_table_id: options.target_table_id,
          id: model_id
        },
        timeout: 15000
      })
    }
    
  }
  emit('after.go_to.' + target, {model_id:model_id, action:action, options:options});
}
