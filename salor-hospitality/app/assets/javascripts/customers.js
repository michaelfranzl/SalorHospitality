/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function add_customers_button() {
  if(_get('customers.button_added')) return
  if(!permissions.manage_customers) return
  opts = {id:'customers_category_button', handlers:{'mousedown':function(){show_customers('#articles')}}, bgcolor:"50,50,50", bgimage:'/assets/category_customer.png', append_to:'#categories'};
  add_category_button(i18n.customers, opts);
  _set('customers.button_added',true);
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