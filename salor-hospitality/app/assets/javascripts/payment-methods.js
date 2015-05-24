/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
  
  payment_method_input_change(pm_input, payment_method_uid, model_id);
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
  change = - (submit_json.totals[mid].model + booking_order_total - payment_method_total);
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