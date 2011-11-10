$('#admin').hide();

// customer pop-up functionality
function customer_list_entry(customer) {
  var entry = $('<div class="customer_search_result" id="customer_' + customer['id']+'"></div>');
  var btn = $("<span class='entry-add-button' customer_id='" + customer['id']+"'> + </span>");
  btn.mousedown(function () {
    var id = '#customer_name_' + $(this).attr('customer_id');
    var field = $('<input type="hidden" name="order[customer_set][][id]" value="' + $(this).attr('customer_id') + '"/>');
    $("#order_form_ajax").append(field);
    $('#order_info').append("<span class='order-customer'>"+$(id).html()+"</span>");
    $(this).parent().hide();
  });
  entry.append(btn);
  entry.append("<span class='entry-customer-name' id='customer_name_" + customer['id'] + "'>" +customer['first_name']+ " " +customer['last_name']+ "</span>");
  return entry;
}

function customer_list_update() {
  $.getJSON('/customers?format=json&keywords=' + $('#customer_list_search').val() , function (data) {
    $('#customer_list_target').html('');
    for (i in data) {
      $('#customer_list_target').append(customer_list_entry(data[i]['customer']));
    }
  });
}

$(function(){
  $("#customer_list_search").keypress(function () {
    if ($(this).val().length > 2) {
      customer_list_update();
    }            
  });
})
