/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function split_item(id, order_id, sum, partner_item_id, increment) {  
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

  if (
    (increment == 1) && (original_count > 0) || (increment == -1) &&
    (split_count > 0)
  ) {
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
    
    if (payment_method_inputs_original.length == 0) {
      return;
    }
    
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

    var timestamp = new Date().getTime();
    $.ajax({
      type: 'PUT',
      url: '/items/split?_=' + timestamp,
      data: {
        jsaction: 'split',
        split_items_hash: submit_json.split_items_hash[order_id],
        order_id: order_id
      },
      timeout: 90000,
      complete: function(data,status) {
        if (status == 'timeout') {
          alert("Der Server hat nach dem Splitten 90 Sekunden lang nicht geantwortet. Bitte zur Überprüfung auf den Bestellbildschirm wecheln und Rechnungsansicht nochmals aufrufen.");
        }
      }
    });
    submit_json.split_items_hash = {}; // prevent from double clicking the button
  }
}