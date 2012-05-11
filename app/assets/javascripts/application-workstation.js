/*
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
*/

function toggle_admin_interface() {
  $.ajax({ type: 'POST', url:'/orders/toggle_admin_interface' });
}

$(document).ready(function() {
  // ":not([safari])" is desirable but not necessary selector
  $('input:checkbox:not([safari])').checkbox();
  $('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
  $('input:radio').checkbox();
  if ($('#flash').children().size() > 0) {
    $('#flash').fadeIn(1000);
    setTimeout(function(){ $('#flash').fadeOut(1000); }, 5000);
  }
})
