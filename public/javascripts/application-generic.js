/*
BillGastro -- The innovative Point Of Sales Software for your Restaurant
Copyright (C) 2011  Michael Franzl <michael@billgastro.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

jQuery.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
    }
})


var tableupdates = -1;
var automatic_printing = 0;
var new_order = true;



window.setInterval(
  function() {
    if ( automatic_printing == true ) {
      window.location.href = '/items.bill';
    }
    if (tableupdates > 0) {
      $.ajax({ url: '/tables' });
    }
    else if (tableupdates == 0) {
      alert(i18n_server_no_response);
    }
    tableupdates -= 1;
  }
, 12000);

function scroll_to(element, speed) {
  target_y = $(window).scrollTop();
  current_y = $(element).offset().top;
  //do_scroll(current_y - target_y, speed);
  window.scrollTo(0, current_y - target_y);
}

function scroll_for(distance, speed) {
  do_scroll(distance, speed);
}

function do_scroll(diff, speed) {
  window.scrollBy(0,diff/speed);
  newdiff = (speed-1)*diff/speed;
  scrollAnimation = setTimeout(function(){ do_scroll(newdiff, speed) }, 20);
  if(Math.abs(diff) < 1) { clearTimeout(scrollAnimation); }
}


