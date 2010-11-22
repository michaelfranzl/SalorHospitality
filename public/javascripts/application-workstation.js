var tableupdates = false; //should correlate with orders_controller, where you can see that session[:admin_interface] = true

function toggle_admin_interface() {
  //var tableupdates will be toggled based on session by remote function
  new Ajax.Request('/orders/toggle_admin_interface', {asynchronous:true, evalScripts:true});
  //Effect.toggle('admin', 'slide');
  if(tableupdates==true) {
    Effect.SlideDown('admin');
  } else {
    Effect.SlideUp('admin');
  }
}

function category_onmousedown(category_id) {
  display_articles(category_id); deselect_all_categories();
}

function display_quantities(art_id) {
  $('quantities').innerHTML = quantitylist[art_id];
}

function hide_optionsselect(what) {
  what.hide();
}

function hide_tableselect(what) {
  what.hide();
}
