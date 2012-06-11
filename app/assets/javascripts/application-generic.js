/*
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
*/

var tableupdates = -1;
var automatic_printing = false;
var debugmessages = [];

$(function(){
  jQuery.ajaxSetup({
      'beforeSend': function(xhr) {
          //xhr.setRequestHeader("Accept", "text/javascript");
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }
  })

  if (typeof(automatic_printing_timeout) == 'undefined') {
    automatic_printing_timeout = window.setInterval(function() {
      if ( automatic_printing == true ) { window.location.href = '/items.bill'; }
    }, 10000);
  }
})

function scroll_to(element, speed) {
  target_y = $(window).scrollTop();
  current_y = $(element).offset().top;
  if (settings.workstation) {
    do_scroll((current_y - target_y)*1.05, speed);
  } else {
    window.scrollTo(0, current_y);
  }
}

function scroll_for(distance, speed) {
  do_scroll(distance, speed);
}

function  in_array_of_hashes(array,key,value) {
  for (var i in array) {
    if (array[i][key]) {
      try {
        if (array[i][key] == value) {
          return true;
        } else if (array[i][key].indexOf(value) != -1){
          return true;
        }
      } catch (e) {
        return false;
      }
    }
  }
  return false;
}

function do_scroll(diff, speed) {
  window.scrollBy(0,diff/speed);
  newdiff = (speed-1)*diff/speed;
  scrollAnimation = setTimeout(function(){ do_scroll(newdiff, speed) }, 20);
  if(Math.abs(diff) < 5) { clearTimeout(scrollAnimation); }
}

function debug(message) {
  if ( debugmessages.length > 7 ) { debugmessages.shift(); }
  debugmessages.push(message);
  $('#messages').html(debugmessages.join('<br />'));
}


function toggle_all_option_checkboxes(source) {
  if ($(source).attr('checked') == 'checked') {
    $('input.category_checkbox:checkbox').attr('checked',true);
  } else {
    $('input.category_checkbox:checkbox').attr('checked',false);
  }
}

function date_as_ymd(date) {
  return date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate();
}
function get_date(str) {
  return new Date(Date.parse(str));
}
