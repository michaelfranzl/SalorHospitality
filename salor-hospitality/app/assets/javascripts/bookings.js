/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var _mouse = { x: 0, y: 0};
var _bounding_boxes = {x:{},y:{}};
var coords = {};

$(function () {
  /* Here we set an interval to redraw the display. It's better this way, so we can have a more direct control
     over the drawing. If we call the redraw inside of functions, it can get out of hand, instead, we need to "mark"
     the buffer as dirty, i.e. with salor_hotel.bookings.dirty. Sometimes, we are doing something like hovering, or
     dragging, and we don't want to be redrawing at these points, so we can set salor_hotel.pause_redraw.
  */
  setInterval(function () {
    if (
      $('#rooms').is(":visible") && 
      !_get("salor_hotel.pause_redraw") && 
      _get("salor_hotel.bookings.dirty") == true
    ) {
      clear_bookings();
      render_booking_lines();
      _set("salor_hotel.bookings.dirty",false);
    }
  },250);
  // We need to know the mouse.x and mouse.y
  $('#rooms_container').mousemove(function (event) {
    _mouse.x = event.pageX;
    _mouse.y = event.pageY;
  });
  

});
/* 
 * Here we get the date from the y coordinate, the x is actually not used in this function.
 * You can pass _mouse.x, _mouse.y, or you can pass $(selector).offset()
 */
function get_date_from_xy(x,y) {
  var ret = null;
  if (typeof x == 'object') {
    y = x.top;
  }
  $.each(_bounding_boxes.y, function (key,value) {
    var pairs = key.split('-');
    var top = parseFloat(pairs[0]);
    var bottom = parseFloat(pairs[1]);
    if (y >= top && y <= bottom) {
      ret = value;
      return;
    }
  });
  return ret;
}
/* 
 * Similar to get_date_from_xy, but uses the x axis to figure out the room. Takes the same arguments, _mouse.x,_mouse.y, or $(selector).offset()
 */
function get_room_from_xy(x,y) {
  var ret = null;
  if (typeof x == 'object') {
    x = x.left;
  }
  $.each(_bounding_boxes.x, function (key,value) {
    var pairs = key.split('-');
    var left = parseInt(pairs[0]);
    var right = parseInt(pairs[1]);
    
    if (x >= left && x <= right) {
      ret = _get("rooms.json").rooms[value];
      return;
    }
  });
  return ret;
}
/* 
 * The inverse of the above, we sometimes need to know the y position for a certain date.
 */
function get_y_by_date(date) {
  var day = date.getDate();
  var month = date.getMonth();
  $.each($('.booking-line'), function () {
    if ($(this).attr('month') == month && $(this).attr('day') == day) {
      return $(this).attr('y');
    }
  });
}
function get_room_from_mouse() {
  return get_room_from_xy(_mouse.x,_mouse.y);
}
function get_day_from_mouse() {
  return get_date_from_xy(_mouse.x,_mouse.y).getDate();
}
function get_booking(id) {
  return _get("rooms.json").bookings[id];
}

function receive_rooms_db (event) {
  var data = event.packet;
  var bookings = [];
  data.get_bookings = function (room_index) {
    room_id = this.keys[room_index - 1]
    if (!room_id)
      return [];
    return this.rooms[room_id + ''].bookings;
  };
  _set("rooms.json",data);
  _set("salor_hotel.bookings.dirty",true);
}

function fetch_rooms () {
  _fetch('/rooms?format=json&from=' + _get("salor_hotel.from_input"), function (data) {
    emit('ajax.rooms_index.success', data);
  });
}
window.update_room_bookings = function (event) {
  // is now done elsewhere
}
function update_bookings_for_room (id,bookings) {
  //console.log("Updating Bookings for room",bookings);
  $.each(bookings, function (index,booking) {
    var found = false;
    for (var i = 0; i < _get("rooms.json").rooms[id].bookings.length;i++) {
      if (_get("rooms.json").rooms[id].bookings[i].id == booking.id) {
        found = true;
        _get("rooms.json").rooms[id].bookings[i] = booking;
      }
    }
    if (!found) 
      _get("rooms.json").rooms[id].bookings.push(booking.id);
    _get("rooms.json").bookings[booking.id.toString()] = booking;
    _set("salor_hotel.bookings.dirty",true);
  });
}
function update_booking_for_room(id,booking) {
  var updated = false;
  try {
    $.each(_get("rooms.json").bookings, function (key,existing_booking) {
      if (existing_booking.id == booking.id) {
        _get("rooms.json").bookings[key] = booking;
      }
    });
  } catch (e) {
    //console.log(e.get_message());
  }
  if (updated == false) {
    _get("rooms.json").rooms[id].bookings.push(booking.id);
    _get("rooms.json").bookings[booking.id.toString()] = booking;
  }
  _set("salor_hotel.bookings.dirty",true);
}
function is_booked_now(booking) {
  var fdate = get_date(booking.from);
  var tdate = get_date(booking.to);
  var now = new Date();
  
  fdate = parseInt(fdate.getMonth() + '' + fdate.getDate());
  tdate = parseInt(tdate.getMonth() + '' + tdate.getDate());
  now = parseInt(now.getMonth() + '' + now.getDate());
//   console.log("Is booked now?",now,fdate,tdate);
  if (now >= fdate && now <= tdate) {
//     console.log("returning true");
    return true
  } else {
//     console.log("returning false");
    return false;
  }
}
function is_in_booking_frame(booking) {
  var fdate = get_date(booking.from);
  var tdate = get_date(booking.to);
  var frame1 = get_date($('#show_booking_from').val());
  var frame2 = get_date($('#show_booking_from').val());
  frame2 = new Date(frame2.getFullYear(),frame2.getMonth(),frame2.getDate() + 31);
  //console.log("is_in_booking_frame dates: ", fdate,tdate,frame1,frame2);
  if (
    (fdate >= frame1 && fdate <= frame2) ||
    (tdate >= frame1 && tdate <= frame2) 
  ) {
    return true;
  } else {
    return false;
  }
}
/* 
 * Finding out if the room is currently booked.
 */
function is_booked (booking,date) {
  if (!booking) {
    return false;
  }
  var fday = get_date(booking.from).getDate();
  var fmonth = get_date(booking.from).getMonth();
  var tday = get_date(booking.to).getDate();
  var tmonth = get_date(booking.to).getMonth();
  var month = date.getMonth();
  var day = date.getDate();
  if (fmonth == date.getMonth() || tmonth == date.getMonth()) {
    if (day >= fday && day <= tday) { 
      //console.log("is_booked returning true");
      return true;
    }
  }
  //console.log("is_booked returning false");
  return false;
}
// just a text formatting helper
function to_day_month(date) {
  return date.getDate() + "/" + (date.getMonth()+1);
}
// Just a format helper
function get_from_to_of_booking(booking) {
  var from = new Date(Date.parse(booking.from));
  var to = new Date(Date.parse(booking.to));
  return to_day_month(from) + ' -> ' + to_day_month(to);
}
/* 
 * Each booking has an inner div with elements, as new features get added, we put the stuff in here.
 */
function booking_build_inner_div(booking) {
  var inner_div = create_dom_element('div',{class:'inner-div'},'','');
  var name_div = create_dom_element('div',{class:'name', booking_id: booking.id, room_id: booking.room_id},booking.customer_name,inner_div);
  inner_div.append("<br />");
  var date_div = create_dom_element('div',{class: 'date',booking_id: booking.id, roomd_id: booking.room_id},get_from_to_of_booking(booking),inner_div);
  var invoice_button = create_dom_element('a', {class:'iconbutton invoice_button'},'',inner_div);
  invoice_button.on('click', function(){window.location = '/bookings/' + booking.id});
  var handle = create_dom_element('span',{class: 'handle', id:'booking_handle_' + booking.id},'',inner_div);
  name_div.on('mouseenter',booking_mouse_enter);
  name_div.on('mouseout',booking_mouse_out);
  name_div.on('click',function () {
    route('booking', booking.id, null, {room_id:booking.room_id});
  });
  return inner_div;
}

// A quick test to see if a booking element exists on the screen
function booking_exists(booking) {
  if ($('#booking_' + booking.id).length > 0) {
    return true;
  }
  return false;
}
/* 
 * Used for the drag/drop editing of the date of the stay.
 */
function get_new_start_end_date(booking_id,new_date) {
  var booking = _get("rooms.json").bookings[booking_id];
  var duration = days_between_dates(booking.from, booking.to);
  var new_end_date = new Date(new_date.getFullYear(),new_date.getMonth(), new_date.getDate() + duration);
  return [date_as_ymd(new_date),date_as_ymd(new_end_date)];
}
// General callback for the mousenter event
function booking_mouse_enter () {
  $.each($('.room-booking'), function () {
    $(this).css({'z-index':1005});
  });
  var booking_widget = $('#booking_' + $(this).attr('booking_id'));
  booking_widget.css({'z-index':1009});
  _set("salor_hotel.pause_redraw",true);
}
// general callback for the mouseout event
function booking_mouse_out () {
  _set("salor_hotel.pause_redraw",false);
  var booking_widget = $('#booking_' + $(this).attr('booking_id'));
  booking_widget.css({'z-index':1005});
}

function finish_booking(booking) {
  var booking_widget = $('#booking_' + booking.id);
  booking_widget.addClass('room-booking-finished');
  booking_widget.removeClass('room-booking-active');
  if (booking_widget.is(":ui-draggable")) {
    booking_widget.draggable('disable');
  }
  booking_widget.find('.name').unbind('click');
  booking_widget.find('.name').on('click', function() { window.location = '/bookings/' + booking.id});
}

function should_i_draw_this_booking(booking) {
  
}

/* 
 * This is the function that we use to actually draw the booking, it should be completely disconnected from everything,
 * just provide it with a booking object, and it will draw it where it is supposed to be.
 */

function draw_booking(booking) {
  if (!$('#rooms').is(":visible")) {
    return;
  }
  if (!is_in_booking_frame(booking)) {
     //console.log("Booking not in this frame",booking);
    return;
  } else {
    //console.log("booking is in this frame",booking);
  }
  // keys is an array where the index of the value matches the index of rooms, because a room_id could be 1, or 1000,
  // this way we can fast looking the room. In the below case, the index of rooms also happens to correlate with the
  // x coordinate.
  var show_booking_from = new Date(Date.parse($('#show_booking_from').val()));
  var x = _get("rooms.json").keys.indexOf(booking.room_id) + 1; // plus 1 because arrays are 0 indexed
  var nights = days_between_dates(booking.from, booking.to);
  //  negative_offset is used to put the div offset halfway inside the div for the arrive at noon leave at noon concept
  var negative_offset = _get("salor_hotel.outerHeight") / 2;
  var tpad = _get("salor_hotel.tpad");
  var lpad = _get("salor_hotel.lpad");
  var owidth = _get("salor_hotel.outerWidth");
  var oheight = _get("salor_hotel.outerHeight");
  var widget_height = oheight * (nights + 1);
  var booking_class = 'odd';
  var offset = $('#rooms').offset();
  var d = get_date(booking.from);
  // We save the y coords when we generate the booking table to make it easier. Used to be a function, but that
  // was problematic.
  var key = (d.getMonth() + 1) + '-' + d.getDate();
  var y = coords[key];
  if (!y)
      y = 1;
  // If the start_date of the booking is before the current view, then we need to 
  // recalculate the number of nights we need to show for this view
  if (Date.parse(booking.from) < show_booking_from) {
    nights = days_between_dates($('#show_booking_from').val(), booking.to);
    y = 1;
  }
  
  if (nights > 31) {
    nights = 31 - y;
  }
  var widget_height = oheight * (nights); // because they leave the afternoon of the next day
  
  // If the booking exists, then we only need to update it.
  if (booking_exists(booking)) {
    var booking_widget = $('#booking_' + booking.id);
    if (booking.hidden == true) {
      booking_widget.remove();
    }
    
    if (booking.finished == true) {
      finish_booking(booking);
    }
    
    d = get_date(booking.from);
    if (y == 1) {
      negative_offset += 10;
      var new_offset = {top: offset.top + ((y * oheight) + (oheight * 1)) - negative_offset + 20, left: offset.left + (owidth * x) + lpad + 10};
      widget_height += 15;
    } else {
      var new_offset = {top: offset.top + ((y * oheight) + (oheight * 1)) - negative_offset + 20, left: offset.left + (owidth * x) + lpad + 10};
    }
    $('#booking_' + booking.id + ' > div.inner-div > span.name').html(booking.customer_name);
    booking_widget.offset(new_offset);
    booking_widget.css({height: widget_height});
    return;
  } // end  if (booking_exists(booking)) {

  // the it's top aligned, probably starts before the current view, so we just move it to the very top
  if (y == 1) {
    negative_offset += 10;
    var new_offset = {top: offset.top + ((y * oheight) + (oheight * 1)) - negative_offset, left: offset.left + (owidth * x) + lpad + 10};
    widget_height += 30; // when we remove the top offset, we have to extend the height of the widget to compensate
  } else {
    var new_offset = {top: offset.top + ((y * oheight) + (oheight * 1)) - negative_offset + 20, left: offset.left + (owidth * x) + lpad + 10};
  }
  
  //_log('using','salor_hotel.booking.odd'+ x, booking.customer_name, booking.id, booking.room_id);

  if (booking.customer_name == '') {
    booking.customer_name = i18n.unamed; // this should never happen, they should always set a customer.
  }
  
  var booking_widget = create_dom_element(  'div', 
                                            { 
                                              booking_id: booking.id,
                                              date: d, 
                                              room_id: booking.room_id,
                                              class: 'room-booking booking-line room-booking-' + booking_class, 
                                              id: 'booking_' + booking.id,
                                              x: x,
                                              y: y
                                            }, 
                                            booking_build_inner_div(booking), 
                                            $('#rooms')
  );
  if (is_booked_now(booking) && !booking.finished == true) {
    booking_widget.addClass('room-booking-active');
  } else if (booking.finished == true) {
    booking_widget.addClass('room-booking-finished');
    if (booking.paid != true)
      booking_widget.addClass('room-booking-unpaid');
  }
  booking_widget.offset(new_offset);
  // We store most of the information to do with the booking
  // right on the element itself in attributes.
  booking_widget.attr('y',new_offset.top);
  booking_widget.attr('x',new_offset.left);
  booking_widget.css({height: widget_height});
  booking_widget.on('mouseenter',booking_mouse_enter);
  booking_widget.on('mouseout',booking_mouse_out);
  if (booking.finished == true) {
    finish_booking(booking);
    return;
  }
  booking_widget.draggable({
    handle: $('#booking_handle_' + booking.id),
    drag: function (event,ui) {
      if (_keys_down.ctrl) { // _keys_down is setup in application-generic.js
        //console.log("Setting option to y");
        $(this).draggable("option","axis","y");
      } else {
        $(this).draggable("option","axis","x");
        //console.log("Setting option to x");
      }
    },
    stop: function () {
      try {
        _set("salor_hotel.pause_redraw",true);
        var room = get_room_from_mouse();
        var booking = get_booking($(this).attr('booking_id'));
        
        //console.log("new start end is: ", new_start_end_date,"Room is:",room.room.id);
        if (room) {
          if (Date.parse(booking.from) > Date.parse($('#show_booking_from').val())){
            // i.e. we  don't update the date unless the booking is fully displayed.
            try {
              var new_start_end_date = get_new_start_end_date($(this).attr('booking_id'),get_date_from_xy( $(this).offset() ));
              var model = { room_id: room.room.id, from_date: new_start_end_date[0], to_date: new_start_end_date[1] };
            } catch (err) {
              //console.log(err);
              var model = { room_id: room.room.id};
            }
          } else {
            var model = { room_id: room.room.id};
          }
          payload = {
            relation: 'bookings',
            id: $(this).attr('booking_id'), 
            model: model
          };
          _push(payload,
                '/route',
                function (data) {
                  update_booking_for_room(data.room_id,data);
                  _set("salor_hotel.pause_redraw",false);
                }, 
                function () {
                  //console.log('call failed');
                  _set("salor_hotel.pause_redraw",false);
                }
         ); // end _push
        } else {
          //console.log("Couldn't get room");
          _set("salor_hotel.pause_redraw",false);
        }

      } catch (e) { 
        //console.log(e.get_message());
      }
    }
  });
}
function clear_bookings() {
  $('.booking-line').remove();
  $('.room-booking').remove();
  $('.booking-line-ender').remove();
}
function draw_bookings() {
//   console.log('draw_bookings called');
  for (var key in _get("rooms.json").bookings) {
    var booking = _get("rooms.json").bookings[key];
    if (booking_exists(booking) && booking.hidden) {
      $('#booking_' + booking.id).remove();
    } else if (!booking.hidden == true) {
//       console.log('draw_bookings',booking);
      draw_booking(booking);
    }
  }
}
// helper for formating the coords[key]
function get_coord_key_from_element(elem,axis) {
  var key = '';
  if (axis == 'y') {
    return elem.offset().top + '-' + (elem.offset().top + elem.outerHeight());
  } else {
    return elem.offset().left + '-' + (elem.offset().left + elem.outerWidth());
  }
}

function render_booking_lines () {
  var num_rooms = _get("rooms.json").keys.length;
  var now = new Date(Date.parse($('#show_booking_from').val()))
  var i = 1
  var rooms_bookings = [];
  var offset = $('#rooms').offset();
  var tpad = _get("salor_hotel.tpad");
  var lpad = _get("salor_hotel.lpad");
  var owidth = _get("salor_hotel.outerWidth") + lpad;
  var oheight = _get("salor_hotel.outerHeight") + tpad;
  var css = {top: offset.top + $('#header').outerHeight(), left: offset.left};
  var existed = false;
  while (i < 32) {
    x = 1
    css = {top: offset.top + (i * oheight) + 20, left: offset.left + lpad};
    var d = new Date(now.getFullYear(),now.getMonth(), now.getDate() + i - 1);
    
    if ($('#booking_date_' + i).length > 0 ) {
      r = $('#booking_date_' + i);
      existed = true;
    } else {     
      var span;
      var new_margin;
      var r = create_dom_element('div', {class: 'room-date-column left booking-line', id: 'booking_date_' + i, y: i, month: d.getMonth(), day: d.getDate() }, '', $('#rooms'));
      var the_day = d.getDate().toString();
      
      for (var jj = 0; jj < num_rooms / 3; jj++) {
        span = $("<span class='date'>"+d.getDate()+"</span>");
        new_margin = (r.outerWidth() / (num_rooms / 3));
        if (the_day.length < 2)
           new_margin += 10;
        span.css({'margin-right': new_margin})
        r.append(span);
      }
    }
    r.offset(css);
    r.css({height: _get("salor_hotel.outerHeight")});
    
    if (i == 31) {
      r.addClass('room-date-column-last');
    }
    _bounding_boxes.y[get_coord_key_from_element(r,'y')] = d;
    var key = (d.getMonth() + 1) + '-' + d.getDate();
    coords[key] = i;
    if (existed == false) {
      $("#rooms").append("<br class='booking-line' />");
    }
    i++;
  }
  if ($('.booking-line-ender').length == 0) {
    $("#rooms").append("<br class='booking-line-ender' />");
  }
  draw_bookings();
}

function show_rooms_interface() {
  $('#booking_form').hide();
  $('#functions_header_index').show();
  $('#tables').hide();
  $('#areas').hide();
  $('#main').hide();
  $('#admin').hide();
  $('#footer').hide();
  $('#copyright').hide();
  $('#spliced_seasons').show();
  $('#rooms').html('');
  var admin_toggle_offset = $('#header').offset();
  $('#rooms').show();
}

function hide_rooms_interface() {
  $('#rooms').hide();
  $('#container').show();
  route('tables');
}

function draw_element(elem,offset,type,css) {
  if (!type) {
    type = 'offset';
  }
  new_offset = offset;
  if (type == 'offset') {
    elem.offset(new_offset);
  } else {
    elem.css(new_offset);
  }
  if (css) {
    elem.css(css);
  }
}

function draw_rooms_header() {
  var offset = $('#rooms').offset();
  var tpad = _get("salor_hotel.tpad");
  var lpad = _get("salor_hotel.lpad");
  if ($('#room_date_select').length > 0) {
    var room = $('#room_date_select');
  } else {
    var room = create_dom_element('div',{'class':"room-header", id: 'room_date_select'},'',$('#rooms'));
    from_input = create_dom_element('input', {type:'text',id:'show_booking_from', value: date_as_ymd(new Date(Date.parse(_get("salor_hotel.from_input"))))}, '', room);
    from_input.datepicker({
      onSelect: function (date, inst) {
        _set("salor_hotel.from_input",$('#show_booking_from').val());
        fetch_rooms();
      }
    });
    from_input.css({width: room.outerWidth() - 10, position: 'relative', top: '5px', left: '5px'});
  }
  var num_rooms = _get("rooms.json").keys.length;
  var new_width = num_rooms * room.outerWidth() + 300;
  $('#rooms').css({'width': new_width + 'px', height: 32 * room.outerHeight() + room.outerHeight()})
  width = (parseInt($('#rooms').parent().width()) / (num_rooms + 2)) + 'px';
  css = {top: offset.top + tpad + 20, left: offset.left + lpad}
  room.offset(css);
  
  _set("salor_hotel.outerWidth", room.outerWidth());
  _set("salor_hotel.outerHeight", room.outerHeight());
  
  $.each(_get("rooms.json").rooms,function (k,v) {
    
    var room = create_dom_element('div',{'class':"room-header",'id': 'room_header_' + v.room.id},v.room.name,$('#rooms'));
    css = {top: css.top, left: room.outerWidth() + css.left};
    // we'll use this to detect the room_id
    draw_element(room,css,'offset');
    _bounding_boxes.x[get_coord_key_from_element(room,'x')] = k;
    var room_column = create_dom_element('div',{'class':"room-column"},'',$('#rooms'));
    var col_css = {top: css.top + room.outerHeight() + tpad, left: css.left};
    draw_element(room_column,col_css,'offset');
    room_column.css({width: room.outerWidth(), height: $('#rooms').outerHeight()})
    var height = (room.outerHeight() + tpad) * 31;
    room_column.css({height: height});
    room.on('click',function () {
      hide_rooms_interface();
      route('room', k);
      submit_json.model.room_id = k;
      submit_json.model.room_type_id = v.room_type.id;
    });
  });
}
// updates the visual room buttons. Hooked into update_resources of the main app.
window.render_rooms = function (event) {
  //if (!$('#rooms').is(":visible")) {
    show_rooms_interface();
  //}
  //if (!_get("salor_hotel.from_input")) {
     var d = new Date();
     d.setDate(d.getDate() - 2);
     //_log(d);
    _set("salor_hotel.from_input",date_as_ymd(d));
  //}
  var offset = $('#rooms').offset();
  var tpad = 0;
  var lpad = 20;
  _set("salor_hotel.tpad",tpad);
  _set("salor_hotel.lpad",lpad);

  draw_rooms_header();
  _set('rooms.rendered',true);
  $('#rooms').append("<br />");
  render_booking_lines()
}
