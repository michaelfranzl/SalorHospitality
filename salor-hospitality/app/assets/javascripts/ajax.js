/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function update_order_from_invoice_form(data, button) {
  data.currentview = 'invoice';
  data.payment_method_items = submit_json.payment_method_items;
  if (! $.isEmptyObject(submit_json.split_items_hash[data.id])) {
    data.split_items_hash = submit_json.split_items_hash[data.id];
  }
  var timestamp = new Date().getTime();
  $.ajax({
    type: 'POST',
    url: '/route?_=' + timestamp,
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
  
  if ($.isEmptyObject(submit_json.split_items_hash[data.id]) &&  data.jsaction != 'change_cost_center' && data.jsaction != 'mass_assign_tax' && data.interim == false) {
    if ($('div.invoice:visible').length == 1) {
      route('tables');
      invoice_update = false;
    } else {
      // stay on invoice page but remove the current invoice from DOM
      invoice_update = true;
      $('#model_' + data.id).hide();
      delete submit_json.split_items_hash[data.id];
    }
  }
 
}

function update_order_from_summary(data) {
  data['currentview'] = 'order_summary';
  $.ajax({
    type: 'GET',
    url: '/route',
    cache: false,
    data: data,
    timeout: 20000
  });
}

function rotate_tax_item(id) {
  $.ajax({
    type: 'PUT',
    url: '/items/rotate_tax',
    data: {id:id},
    timeout: 20000
  });
}

function toggle_drag_tables() {
  switch(toggle_drag_tables_state) {
    case 0:
      // dragging is off
      // turn dragging on
      counter_update_tables = -1;
      settings.workstation_drag_and_drop = true;
      toggle_drag_tables_state++;
      break;
    case 1:
      // dragging is on for workstation table positions
      // switch to mobile table positions
      $('#areas').show();
      $('.mobile_last_invoices_button').hide();
      settings.workstation_drag_and_drop = false;
      settings.mobile_drag_and_drop = true;
      toggle_drag_tables_state++;
      break;
    case 2:
      // dragging is on for mobile table positions
      // switch to workstation table positions and turn dragging off
      counter_update_tables = timeout_update_tables;
      $('#areas').hide();
      $('.mobile_last_invoices_button').show();
      settings.workstation_drag_and_drop = false;
      settings.mobile_drag_and_drop = false;
      toggle_drag_tables_state = 0;
      break;
  }
  render_tables();
}