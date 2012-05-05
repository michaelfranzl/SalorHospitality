var automatic_printing = 0;
var new_order = true;
var option_position = 0;
var item_position = 0;

var items_json = {};
var submit_json = {};
var items_json_queue = {};
var submit_json_queue = {};
var customers_json = {};

function display_articles(cat_id) {
  $('#articles').html('');
  jQuery.each(resources.c[cat_id].a, function(art_id,art_attr) {
    a_object = this;
    abutton = $(document.createElement('div'));
    abutton.addClass('article');
    abutton.html(art_attr.n);
    qcontainer = $(document.createElement('div'));
    qcontainer.addClass('quantities');
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
        var catid = cat_id;
        abutton.on('click', function() {
          highlight_border(element)
          $('.quantity').remove();
          add_new_item(object, catid);
        });
      })();
    } else {
      // quantity
      arrow = $(document.createElement('img'));
      arrow.addClass('more');
      arrow.attr('src','/images/more.png');
      abutton.append(arrow);
      (function() {
        abutton.on('click', function(event) {
          var quantities = resources.c[cat_id].a[art_id].q;
          var target = qcontainer;
          var catid = cat_id;
          display_quantities(quantities, target, catid);
        });
      })();
    }
    //abutton.append(qcontainer);
    qcontainer.insertAfter(abutton);
  });
}

function display_quantities(quantities, target, cat_id){
  target.html('');
  jQuery.each(quantities, function(qu_id,qu_attr) {
    q_object = this;
    qbutton = $(document.createElement('div'));
    qbutton.addClass('quantity');
    qbutton.html(qu_attr.pre + qu_attr.post);
    (function() {
      var element = qbutton;
      var quantity = q_object;
      var catid = cat_id;
      qbutton.on('click', function(event) {
        add_new_item(quantity, catid);
        highlight_button(element);
        highlight_border(element);
      });
    })();
    target.append(qbutton);
  })
}

function add_new_item(object, catid, add_new, anchor_d) {
  if (items_json.hasOwnProperty(object.d) &&
      !add_new &&
      items_json[object.d].price == object.price &&
      items_json[object.d].o == '' &&
      items_json[object.d].x == false &&
      $.isEmptyObject(items_json[object.d].i)
     ) {
    // selected item is already there
    increment_item(object.d);
  } else {
    d = create_json_record(object);
    label = compose_label(object);
    new_item = $(new_item_tablerow.replace(/DESIGNATOR/g, d).replace(/COUNT/g, 1).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, '').replace(/PRICE/g, object.price).replace(/LABEL/g, label).replace(/OPTIONSNAMES/g, ''));
    if (anchor_d) {
      $(new_item).insertBefore($('#item_'+anchor_d));
    } else {
      $('#itemstable').prepend(new_item);
    }
    $('#tablerow_' + d + '_count').addClass('updated');
    render_options(resources.c[catid].o, d, catid);
  }
  calculate_sum();
  return d
}

// todo: keep separate optionslist in items_json and submit_json
// disable vendors when vendor count is 1
// escper integration
// category separation on receipts
// make font on receipts smaller
// order moving
// remove all items
// --
// mobile options



function render_items_from_json(json_items) {
  var i;
  for (i in json_items) {
    var object = json_items[i];
    catid = object.catid;
    tablerow = new_item_tablerow.replace(/DESIGNATOR/g, object.d).replace(/COUNT/g, object.count).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, object.o).replace(/USAGE/g, object.u).replace(/PRICE/g, object.price).replace(/LABEL/g, compose_label(object)).replace(/OPTIONSNAMES/g, compose_optionnames(object))
//.replace(/ITEMID/g, item.id)
    $('#itemstable').append(tablerow);
    enable_keyboard_for_items(i);
    render_options(resources.c[catid].o, object.d, catid);
  }
  calculate_sum();
}

function render_customers_from_json(json_items) {
  for (o in order_customers) {
    var customer = order_customers[o]["customer"]
    $('#order_info').append("<span class='order-customer'>"+customer["first_name"]+" "+customer["last_name"]+"</span>");
  }
}

function increment_item(d) {
  count = items_json[d].count + 1;
  object = items_json[d];
  set_json(object.d,'count',count)
  $('#tablerow_' + d + '_count').html(count);
  $('#tablerow_' + d + '_count').addClass('updated');
  calculate_sum();
}

function decrement_item(d) {
  var i = items_json[d].count;
  var start_count = items_json[d].sc;
  if ( i > 1 && ( permission_decrement_items || i > start_count ) ) {
    i--;
    set_json(d,'count',i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
  } else if ( i == 1 && ( permission_decrement_items || ( ! d.hasOwnProperty('id') ))) {
    i--;
    set_json(d,'count',i)
    $('#tablerow_' + d + '_count').html(i);
    $('#tablerow_' + d + '_count').addClass('updated');
    if (permission_delete_items) {
      if (d.indexOf('i') == -1) {
        // the server has never seen this item, so we just delete frmo submit_json
        delete submit_json.items[d];
      } else {
        // the server will delete this item
        set_json(d,'x',true);
      }
      $('#item_' + d).fadeOut('slow');
    }
  };
  calculate_sum();
}

// this function sets attributes for items_json and submit_json objects
function set_json(d,attribute,value) {
  if (items_json.hasOwnProperty(d)) {
    items_json[d][attribute] = value;
  } else {
    alert('Unexpected error: Object items_json doesnt have the property ' + d + ' yet');
  }
  create_submit_json_record(d,items_json[d]);
  submit_json.items[d][attribute] = value;
}


// this creates a new json record
function create_json_record(object) {
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
  items_json[d] = {article_id:object.article_id, quantity_id:object.quantity_id, d:d, count:1, o:'', t:{}, i:[], x:false, price:object.price, prefix:'', postfix:'', s:s};
  if ( ! object.hasOwnProperty('quantity_id')) { delete items_json[d].quantity_id; }
  create_submit_json_record(d,items_json[d]);
  return d;
}

// this creates a new record, copied from items_json, which must exist
function create_submit_json_record(d, object) {
  if ( ! submit_json.items.hasOwnProperty(d)) {
    submit_json.items[d] = {id:object.id, article_id:object.article_id, quantity_id:object.quantity_id, s:object.s};
    if (items_json[d].hasOwnProperty('id')) {
      delete submit_json.items[d].article_id;
      delete submit_json.items[d].quantity_id;
    }
    if ( ! items_json[d].hasOwnProperty('quantity_id')) {
      delete submit_json.items[d].quantity_id;
    }
  }
}



function compose_label(object){
  if ( object.hasOwnProperty('qid') || object.hasOwnProperty('quantity_id')) {
    object_type = 'quantity';
    label = object.pre + ' ' + object.n + ' ' + object.post;
  } else {
    object_type = 'article';
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
    sum += this.count * this.price;
    // now add option prices:
    jQuery.each(this.t, function() {
      sum += this.p;
    });
  });
  $('#order_sum').html(sum.toFixed(2).replace('.', i18n_decimal_separator));
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





function go_to(table_id, view, action, target_table_id) {
  scroll_to($('#container'),20);
  if ( view == 'table' ) {
    submit_json = {items:{}, order:{id:'', table_id:table_id}, state:{}};
    items_json = {};
    $.ajax({ type: 'GET', url: '/tables/' + table_id, timeout: 5000 });
    $('#order_sum').html('0' + i18n_decimal_separator + '00');
    $('#order_info').html(i18n_just_order);
    $('#order_note').val('');
    $('#inputfields').html('');
    $('#itemstable').html('');
    $('#articles').html('');
    $('#quantities').html('');
    $('#orderform').show();
    $('#invoices').hide();
    $('#tables').hide();
    $('#rooms').hide();
    $('#functions_header_index').hide();
    $('#functions_header_invoice_form').hide();
    $('#functions_header_order_form').show();
    if (mobile == true) { $('#functions_footer').show(); }
    screenlock_counter = -1;
    tableupdates = -1;
    screenlock_active = true;
  } else if ( view == 'tables') {
    $('#orderform').hide();
    $('#invoices').hide();
    $('#tables').show();
    $('#rooms').show();
    $('#functions_header_index').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_invoice_form').hide();
    $('#functions_footer').hide();
    $('#customer_list').hide();
    $('#tablesselect').hide();
    //$('#save_and_go_to_tables').css('backgroundImage', 'url("/images/button_mobile_tables.png")');
    //$('#save_and_go_to_tables').css('border','none');
    if (action == 'destroy'){
      submit_json.state['action'] = action;
      submit_json.state['target'] = view;
      send_json(table_id);
    } else if (action == 'send') {
      submit_json.state['action'] = action;
      submit_json.state['target'] = view;
      submit_json.order['note'] = $('#order_note').val();
      send_json(table_id);
    } else if (action == 'move') {
      $(".tablesselect").slideUp();
      submit_json.state['action'] = action;
      submit_json.state['target'] = view;
      submit_json.state['target_table_id'] = target_table_id;
      send_json(table_id);
    }
    screenlock_counter = screenlock_timeout;
    submit_json = {};
    items_json = {};
    option_position = 0;
    item_position = 0;
    tableupdates = 2;
  } else if ( view == 'invoice') {
    submit_json.state['action'] = action;
    submit_json.state['target'] = view;
    submit_json.order['note'] = $('#order_note').val();
    send_json(table_id);
    $('#invoices').html('');
    $('#invoices').show();
    $('#orderform').hide();
    $('#tables').hide();
    $('#rooms').hide();
    $('#inputfields').html('');
    $('#itemstable').html('');
    $('#functions_header_invoice_form').show();
    $('#functions_header_order_form').hide();
    $('#functions_header_index').hide();
    $('#functions_footer').hide();
    tableupdates = -1;
    screenlock_counter = -1;
  }
}


function send_json(table_id) {
  submit_json_queue[table_id] = submit_json;
  send_queue(table_id);
}

function send_queue(i) {
  $.ajax({
    type: 'post',
    url: '/orders/receive_order_attributes_ajax',
    data: submit_json_queue[i],
    success: function(data) {
      if (data['success'] == true) {
        update_tables();
        clear_queue(i);
      }
    }
  });
}

function clear_queue(i) {
  delete submit_json_queue[i];
  $('#queue_'+i).remove();
}

// periodically displays the contents of submit_json_queue
function display_queue() {
  $('#queue').html('');
  jQuery.each(submit_json_queue, function(k,v) {
    el = $(document.createElement('div'));
    el.attr('id','queue_'+k);
    link = $(document.createElement('a'));
    link.html('send ' + k);
    (function(){
      var id = k;
      link.on('click', function() {
        send_queue(id);
      })
    })();
    el.append(link);
    $('#queue').append(el);
  });
}

function update_tables(){
  $.ajax({
    url: '/tables',
    timeout: 5000
  });
}

function change_item_status(id,status) {
  $.ajax({
    type: 'POST',
    url: '/items/change_status?id=' + id + '&status=' + status
  });
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
      //restore_border(cats[c]); // this hangs the browser for no obvious reason
    }
  }
}

$(function(){
  window.setInterval(
    function(){
      $.ajax({
        type: 'GET',
        url: '/items/list?scope=preparation'
      });
      $.ajax({
        type: 'GET',
        url: '/items/list?scope=delivery'
      });
    }
  , 20000);
  
  // display initial items notifications
  $.ajax({
    type: 'GET',
    url: '/items/list?scope=preparation'
  });
  $.ajax({
    type: 'GET',
    url: '/items/list?scope=delivery'
  });
})

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
