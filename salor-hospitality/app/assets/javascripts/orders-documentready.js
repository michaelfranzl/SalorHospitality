$(function(){
  update_resources('documentready');
  
  if (typeof(manage_counters_interval) == 'undefined') {
    manage_counters_interval = window.setInterval("manage_counters();", 1000);
  }
  
  if (!_get('customers.button_added')) {
    connect('customers_entry_hook','after.go_to.table',add_customers_button);
  }
  
  if (!_get('dmenucard.button_added')) {
    connect('dmenucard_entry_hook','after.go_to.table',add_dmenucard_button);
  }
  
  if (settings.workstation) {
    $("#sku_input").on("keypress", function(e) {
      if(e.which == 13) {
        add_item_by_sku($(this).val());
        $("#sku_input").val("");
        $("#sku_input").focus();
      }
    });
    
    $("#sku_input").on("click", function() {
      $("#sku_input").select();
    });
  }
})