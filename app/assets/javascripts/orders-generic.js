function display_items(cat_id) {
  $('#articles').html('');
  jQuery.each(resources.c[cat_id].a, function(art_id,art_attr) {
    a_object = this;
    abutton = $(document.createElement('div'));
    abutton.addClass('article');
    abutton.html(art_attr.n);
    qcontainer = $(document.createElement('div'));
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
        abutton.on('click', function() {
          highlight_border(element)
          add_new_item(a_object);
        });
      })();
    } else {
      arrow = $(document.createElement('img'));
      arrow.addClass('more');
      arrow.attr('src','/images/more.png');
      abutton.append(arrow);
      (function() {
        abutton.on('click', function() {
          var quantities = resources.c[cat_id].a[art_id].q;
          var target = qcontainer;
          display_quantities(quantities, target);
          abutton.off();
        });
      })();
    }
    abutton.append(qcontainer);
  });
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

function highlight_button(element) {
  $(element).effect("highlight", {}, 300);
}

function highlight_border(element) {
  $(element).css('borderColor', 'white');
}

function restore_border(element) {
  $(element).css({ borderColor: '#555555 #222222 #222222 #555555' });
}

function display_quantities(quantities, target){
  jQuery.each(quantities, function(qu_id,qu_attr) {
    q_object = this;
    qbutton = $(document.createElement('div'));
    qbutton.addClass('quantity');
    qbutton.html(qu_attr.pre + qu_attr.post);
    (function() {
      var element = qbutton;
      qbutton.on('click', function() {
        add_new_item(q_object);
        highlight_button(element);
        highlight_border(element);
      });
    })();
    target.append(qbutton);
  })
}


function add_new_item(object, add_new, insert_after_element, sort) {
  var timestamp = new Date().getTime();
  if ( sort == null ) { sort = timestamp.toString().substr(-9,9); }
  var desig = 'new_' + sort;

  if ( object.qid != '' ) {
    object_type = 'quantity';
    label = object.pre + ' ' + object.n + ' ' + object.post;
  } else {
    object_type = 'article';
    label = object.n;
  }


  optionsdiv= '';
  optionsselect= '';
  //if (optionsselect[category_id]) {
  //  var options_select = optionsselect[category_id];
  //} else {
  //  var options_select = ' ';
  //}
  //if (optionsdiv[category_id]) {
  //  var options_div = optionsdiv[category_id];
  //} else {
  //  var options_div = ' ';
  //}

  //var id_fields = $('#inputfields .' + object_type + '_id');
  //for (i = 0; i < id_fields.length; i++) {
  //  if (object.id == id_fields[i].value) {
  //    var matched = id_fields[i];
  //    matched.id.match(/^order_items_attributes_(.*?)_.*$/);
  //    var matched_designator = RegExp.$1;
  //    break;
  //  }
  //};
  //if (matched_designator &&
  //    !add_new && // explicitely disallow incrementing other items, but create a new item instead
  //    $('#order_items_attributes_' + matched_designator + '_price').val() == source.p &&
  //    $('#order_items_attributes_' + matched_designator + '_comment').val() == '' &&
  //    $('#order_items_attributes_' + matched_designator + '_usage').val() == 0 &&
   //   $('#order_items_attributes_' + matched_designator + '__destroy').val() != 1 &&
  //    $('#order_items_attributes_' + matched_designator + '_optionslist').val() == ''
  //   ) {
  //  increment_item(matched_designator);
  //} else {



  new_item = $(new_item_tablerow.replace(/DESIGNATOR/g, object.d).replace(/COUNT/g, 1).replace(/ARTICLEID/g, object.aid).replace(/QUANTITYID/g, object.qid).replace(/COMMENT/g, '').replace(/USAGE/g, '').replace(/POSITION/g, sort).replace(/PRICE/g, object.p).replace(/OPTIONSLIST/g, '').replace(/LABEL/g, label).replace(/OPTIONSDIV/g, optionsdiv).replace(/OPTIONSSELECT/g, optionsselect).replace(/OPTIONSNAMES/g, ''));
  if (insert_after_element) {
    $(new_item).insertBefore(insert_after_element);
  } else {
    $('#itemstable').prepend(new_item);
  }
  new_item.addClass('updated');
  keep_fields_of_item(desig, '_article_id');

  resources['pending']=

  calculate_sum();
  return desig;
}

function add_items_from_json(json_items) {
  var i;
  for (i in json_items) {
    var item = json_items[i];
    tablerow = new_item_tablerow.replace(/DESIGNATOR/g, item.d).replace(/COUNT/g, item.i).replace(/ARTICLEID/g, item.aid).replace(/QUANTITYID/g, item.qid).replace(/COMMENT/g, item.c).replace(/USAGE/g, item.u).replace(/POSITION/g, item.s).replace(/PRICE/g, item.p).replace(/OPTIONSLIST/g, item.o).replace(/LABEL/g, item.l).replace(/OPTIONSDIV/g, optionsdiv).replace(/OPTIONSSELECT/g, optionsselect).replace(/OPTIONSNAMES/g, item.on)
//.replace(/ITEMID/g, item.id)
    $('#itemstable').append(tablerow);
    enable_keyboard_for_items(i);
  }
}


function increment_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  i++;
  $('#order_items_attributes_' + desig + '_count').val(i);
  $('#tablerow_' + desig + '_count').html(i);
  $('#tablerow_' + desig + '_count').addClass('updated');
  keep_fields_of_item(desig,'_count');
  calculate_sum();
}

function decrement_item(desig) {
  var i = parseInt($('#order_items_attributes_' + desig + '_count').val());
  var start_count = parseInt($('#item_' + desig + '_start_count').val());
  if ( i > 1 && ( permission_decrement_items || i > start_count ) ) {
    i--;
    $('#order_items_attributes_' + desig + '_count').val(i);
    keep_fields_of_item(desig,'_count');
    $('#tablerow_' + desig + '_count').html(i);
    $('#tablerow_' + desig + '_count').addClass('updated');
  } else if ( i == 1 && ( permission_decrement_items || (desig.search(/new_.+/) != -1 ))) {
    i--;
    $('#order_items_attributes_' + desig + '_count').val(i);
    keep_fields_of_item(desig,'_count');
    $('#tablerow_' + desig + '_count').html(i);
    $('#tablerow_' + desig + '_count').addClass('updated');
    if (permission_delete_items) {
      $('#order_items_attributes_' + desig + '__destroy').val(1);
      $('#item_' + desig).fadeOut('slow');
      keep_fields_of_item(desig,'__destroy');
    }
  };
  calculate_sum();
}




function calculate_sum() {
  var items = $('#inputfields > div');
  var sum = 0;
  var itemcount;
  var itemprice;
  var options;
  for(i=0; i<items.length; i++) {
    itemcount = parseFloat($(items[i]).children('.count')[0].value);
    itemprice = parseFloat($(items[i]).children('.price')[0].value);
    sum += itemcount * itemprice;
    options = $(items[i]).children('div').children('.optionprice');
    for(j=0; j<options.length; j++) {
      optionprice = parseFloat(options[j].value);
      sum += optionprice * itemcount;
    }
  }
  $('#order_sum').val(sum.toFixed(2).replace('.', i18n_decimal_separator));
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

function add_option_to_item_from_select(item_designator, select_tag)
{
  original_designator = item_designator;

  if ($('#order_items_attributes_' + item_designator + '_optionslist').val() == '' && $('#order_items_attributes_' + item_designator + '_count').val() != 1 && select_tag.value > 0) {

    var quantity_id = $('#order_items_attributes_' + item_designator + '_quantity_id').val();
    var sort = parseInt($('#order_items_attributes_' + item_designator + '_sort').val());
  
    if ( quantity_id != '') {
      cloned_item_designator = add_new_item_q(quantity_id, true, $('#item_' + item_designator), sort - 1);
    } else {
      var article_id = $('#order_items_attributes_' + item_designator + '_article_id').val();
      cloned_item_designator = add_new_item_a(article_id, true, $('#item_' + item_designator), sort - 1);
    }
    decrement_item(item_designator);
    item_designator = cloned_item_designator;
  }

  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);
  var itemoptions = $('#options_for_item_' + item_designator);

  if (select_tag.value == 0) {
    // delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    keep_fields_of_item(item_designator,'_optionslist');
    $('#optionsnames_' + item_designator).html('');
    itemoptions.html('');

  } else if (select_tag.value == -2 ) {
    // just exit, do nothing

  } else if (select_tag.value == -1 ) {
    // special option: do not print
    $('#item_' + item_designator + '_printed_count').val($('#item_' + item_designator + '_count').val());
    keep_fields_of_item(item_designator,'_printed_count');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else if (select_tag.value == -3 ) {
    // special option: takeaway
    $('#order_items_attributes_' + item_designator + '_usage').val(1);
    keep_fields_of_item(item_designator,'_usage');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_takeaway);

  } else {
    // options from database
    optionslist = $('#order_items_attributes_' + item_designator + '_optionslist').val();
    $('#order_items_attributes_' + item_designator + '_optionslist').val(optionslist + select_tag.value + ' ');
    keep_fields_of_item(item_designator,'_optionslist');
    var index = $('#optionsselect_select_' + original_designator).attr('selectedIndex');
    var text = $('#optionsselect_select_' + original_designator).attr('options')[index].text;
    $('#optionsnames_' + item_designator).append('<br>' + text);
    itemoptions.append('<input id="item_' + item_designator + '_option_' + select_tag.value + '" class="optionprice" type="hidden" value="' + optionsdetails[select_tag.value][0] + '">');
  }
  $('#optionsselect_select_' + item_designator).val(-2); //reset
  calculate_sum();
}

function add_option_to_item_from_div(button, item_designator, value, price, text)
{

  if ($('#order_items_attributes_' + item_designator + '_optionslist').val() == '' && $('#order_items_attributes_' + item_designator + '_count').val() != 1 && value > 0) {

    var quantity_id = $('#order_items_attributes_' + item_designator + '_quantity_id').val();
    var sort = parseInt($('#order_items_attributes_' + item_designator + '_sort').val());
  
    if ( quantity_id != '') {
      cloned_item_designator = add_new_item_q(quantity_id, true, $('#item_' + item_designator), sort - 1);
    } else {
      var article_id = $('#order_items_attributes_' + item_designator + '_article_id').val();
      cloned_item_designator = add_new_item_a(article_id, true, $('#item_' + item_designator), sort - 1);
    }
    decrement_item(item_designator);
    $('#optionsselect_div_' + item_designator).slideUp();
    item_designator = cloned_item_designator;
  }

  var tablerow = $('#item_' + item_designator);
  var itemfields = $('#fields_for_item_' + item_designator);
  var itemoptions = $('#options_for_item_' + item_designator);

  if (value == 0) {
    // normal, delete all options
    $('#order_items_attributes_' + item_designator + '_optionslist').val('');
    keep_fields_of_item(item_designator,'_optionslist');
    $('#optionsnames_' + item_designator).html('');
    itemoptions.html('');

  } else if (value == -2 ) {
    $('#options_select_div_' + item_designator).slideUp(); // just exit
  } else if (value == -1 ) {
    // special option: do not print
    $('#item_' + item_designator + '_printed_count').val($('#item_' + item_designator + '_printed_count').val());
    keep_fields_of_item(item_designator,'_printed_count');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_no_printing);

  } else if (value == -3 ) {
    // special option: takeaway
    $('#order_items_attributes_' + item_designator + '_usage').val(1);
    keep_fields_of_item(item_designator,'_usage');
    $('#optionsnames_' + item_designator).append('<br>' + i18n_takeaway);
  } else {
    optionslist = $('#order_items_attributes_' + item_designator + '_optionslist').val();
    $('#order_items_attributes_' + item_designator + '_optionslist').val(optionslist + value + ' ');
    keep_fields_of_item(item_designator,'_optionslist');
    $('#optionsnames_' + item_designator).append('<br>' + text);
    itemoptions.append('<input id="item_' + item_designator + '_option_' + value + '" class="optionprice" type="hidden" value="' + price + '">');
  }

  calculate_sum();
  $(button).effect("highlight", {}, 1000);
}


//this works also if offline. will be repeated in view of remote function.
function go_to_order_form_preprocessing(table_id) {
  scroll_to($('#container'),20);
  $('#order_sum').value = '0';

  $('#order_id').val('add_offline_items_to_order');
  $('#order_info').html(i18n_just_order);
  $('#order_note').val('');
  $('#order_action').val('');
  $('#order_table_id').val(table_id);

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
  $('#functions_footer').show();
  $.ajax({ type: 'GET', url: '/tables/' + table_id });
  screenlock_counter = -1;
}

function go_to_tables_offline() {
  scroll_to($('#container'),20);
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
  $('#save_and_go_to_tables').css('backgroundImage', 'url("/images/button_mobile_tables.png")');
  $('#save_and_go_to_tables').css('border','none');
  screenlock_counter = screenlock_timeout;
}

function save_and_go_to_tables() {
  $("#order_action").val("save_and_go_to_tables");
  remove_nonkeep_fields();
  $("#order_form_ajax").submit();
}

function save_and_go_to_invoice() {
  $("#order_action").val("save_and_go_to_invoice");
  remove_nonkeep_fields();
  $("#order_form_ajax").submit();
}

function cancel_all_items_in_active_order() {
  $("#order_action").val("clear_order_and_go_back");
  $("#order_form_ajax").submit();
}

function remove_nonkeep_fields() {
  $('input[keep=0]').remove();
}

function move_order_to_table(id) {
  if ( id != "" ) {
    $(".tablesselect").slideUp();
    $("#order_action").val("move_order_to_table");
    $("#target_table").val(id);
    $("#order_form_ajax").submit();
  }
}

function change_item_status(id,status) {
  $.ajax({
    type: 'POST',
    url: '/items/change_status?id=' + id + '&status=' + status
  });
}

function keep_fields_of_item(desig,field) {
  $('#order_items_attributes_' + desig + '_id').attr('keep', 1);
  $('#order_items_attributes_' + desig + field).attr('keep', 1);
}

$(function(){
	var tableupdates = -1;
	var automatic_printing = 0;
	var new_order = true;

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
