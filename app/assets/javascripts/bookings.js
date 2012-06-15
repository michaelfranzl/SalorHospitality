
window.receive_rooms_db = function (event) {
  var data = event.packet;
  var bookings = [];
  data.get_bookings = function (room_index) {
    room_id = this.keys[room_index - 1]
    if (!room_id)
      return [];
    return this.rooms[room_id + ''].bookings;
  };
  _set("rooms.json",data);
  if ($('#rooms').is(":visible"))
    emit('salor_hotel.render_rooms',data);
}

window.fetch_rooms = function () {
  _fetch('/rooms?format=json', function (data) {
    emit('ajax.rooms_index.success', data);
  });
}
window.update_room_bookings = function (event) {
  var b = event.packet.model;
  var booking = {f: b['from'], t:b['to'], cid: b['customer_id'], sid: b['season_id'], d:b['duration'] };
  resources.r[b.room_id].bks.push(booking);
}
window.update_bookings_for_room = function (id,booking) {
  var updated = false;
  for (var i = 0; i < _get("rooms.json").rooms[id].bookings.length; i++) {
    if (_get("rooms.json").rooms[id].bookings[i].id == booking.id) {
      _get("rooms.json").rooms[id].bookings[i] = booking;
      updated = true;
    }
  }
  if (!updated)
    _get("rooms.json").rooms[id].bookings.push(booking);
}
function is_booked_now(booking) {
  var fdate = get_date(booking.from);
  var tdate = get_date(booking.to);
  var now = new Date();
  if (now >= fdate && now <= tdate) {
    return true
  } else {
    return false;
  }
}
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
      return true;
    }
  }
  return false;
}

function draw_booking(d,y,booking) {
  if ($('#booking_' + booking.id).length > 0) {
    return;
  }
  // keys is an array where the index of the value matches the index of rooms, because a room_id could be 1, or 1000,
  // this way we can fast looking the room. In the below case, the index of rooms also happens to correlate with the
  // x coordinate.
  var x = _get("rooms.json").keys.indexOf(booking.room_id) + 1; // plus 1 because arrays are 0 indexed
  var nights = days_between_dates(booking.from, booking.to);
  var tpad = _get("salor_hotel.tpad");
  var lpad = _get("salor_hotel.lpad");
  var owidth = _get("salor_hotel.outerWidth");
  var oheight = _get("salor_hotel.outerHeight");
  var widget_height = oheight * (nights + 1);
  var booking_class;
  var offset = $('#rooms').offset();
  var new_offset = {top: offset.top + ((y * oheight) + (oheight * 1)) - 25 + $('#header').outerHeight() + 20, left: offset.left + (owidth * x) + lpad + 5};
  
  //_log('using','salor_hotel.booking.odd'+ x, booking.customer_name, booking.id, booking.room_id);
  
  if (_get('salor_hotel.booking.odd'+ x) == false) {
    booking_class = 'odd';
    _set('salor_hotel.booking.odd'+ x,3);
  } else if (_get('salor_hotel.booking.odd'+ x) == 3) {
    booking_class = 'thirden';
    _set('salor_hotel.booking.odd'+ x,true);
  } else {
    booking_class = 'even';
    _set('salor_hotel.booking.odd'+ x,false);
  }
  if (booking.customer_name == '') {
    booking.customer_name = i18n.unamed;
  }
  var booking_widget = create_dom_element(  'div', 
                                            { 
                                              booking_id: booking.id,
                                              date: d, 
                                              room_id: booking.room_id,
                                              class: 'room-booking booking-line room-booking-' + booking_class, 
                                              id: 'booking_' + booking.id
                                            }, 
                                            booking.customer_name, 
                                            $('#rooms')
  );
  if (is_booked_now(booking)) {
    booking_widget.addClass('room-booking-active');
  }
  booking_widget.offset(new_offset);
  booking_widget.css({height: widget_height});
  booking_widget.on('click',function () {
    $('#rooms').hide();
    $('#container').show();
    var room_id = $(this).attr('room_id');
    route('booking', room_id,'show',{'booking_id': $(this).attr('booking_id')});
    submit_json.model.room_id = x;
    submit_json.model.room_type_id = _get("rooms.json").rooms[room_id].room_type.id;
  });
  booking_widget.on('mouseenter',function () {
    $.each($('.room-booking'), function () {
        $(this).css({'z-index':1005});
    });
    $(this).css({'z-index':1009});
   });
  booking_widget.on('mouseout',function () {
    $(this).css({'z-index':1005});
  });
}
function clear_bookings() {
  $('.booking-line').remove();
  $('.room-booking').remove();
  $('.booking-line-ender').remove();
}
window.render_booking_lines = function () {
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
    css = {top: offset.top + (i * oheight) + $('#header').outerHeight() + 20, left: offset.left + lpad};
    var d = new Date(now.getFullYear(),now.getMonth(), now.getDate() + i - 1);
    
    if ($('#booking_date_' + i).length > 0 ) {
      r = $('#booking_date_' + i);
      existed = true;
    } else {
      var r = create_dom_element('div', {class: 'room-date-column left booking-line', id: 'booking_date_' + i }, d.getDate(), $('#rooms'));
    }
    r.offset(css)
    if (i == 31) {
      r.addClass('room-date-column-last');
    }
    while (x <= num_rooms + 1) {
      var room_id = x;
      if (_get("rooms.json").keys[x-1]) {
        if (!rooms_bookings[x]) {
          //_log("rooms_bookings was not set, setting it");
          rooms_bookings[x] = _get("rooms.json").get_bookings(x);
        }
        bookings = rooms_bookings[x];
        //_log("Bookings: ",bookings);
        if (bookings) {
          $.each(bookings, function (b) {
            if (is_booked(bookings[b],d)) {
              //_log("Drawing Booking: ", bookings[b]);
              draw_booking(d,i,bookings[b]);
            } else {
              //_log("is_booked false for booking: ", bookings[b]);
            }
          });
        } else {
          //_log("Empty bookings");
        }
      }
      x++ ;
    }
    if (existed == false) {
      $("#rooms").append("<br class='booking-line' />");
    }
    i++;
  }
  if ($('.booking-line-ender').length == 0) {
    $("#rooms").append("<br class='booking-line-ender' />");
  }
}
function show_rooms_interface() {
  $('#booking_form').hide();
  $('#functions_header_index').show();
  $('#tables').hide();
  $('#areas').hide();
  $('#container').hide();
  $('#rooms').html('');
  var admin_toggle_offset = $('#header').offset();
  $('#rooms').show();
  $('#rooms').offset({top: 0, left: 0});
  var new_header = $('#header').clone();
  new_header.addClass('rooms-container-header');
  new_header.find('').on('click',function () {
    hide_rooms_interface();
  });
  $('#rooms').prepend(new_header);
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
  var room = create_dom_element('div',{'class':"room-header", id: 'room_date_select'},'',$('#rooms'));
  var num_rooms = _get("rooms.json").keys.length;
  var new_width = num_rooms * 200 + 300;
  if (new_width < $(window).width() - 5) {
    new_width = $(window).width() - 5;
  }
  $('#rooms').css({'width': new_width + 'px', height: 32 * 50})
  width = (parseInt($('#rooms').parent().width()) / (num_rooms + 2)) + 'px';
  css = {top: offset.top + tpad + $('#header').outerHeight() + 20, left: offset.left + lpad}
  room.offset(css);
  
  _set("salor_hotel.outerWidth", room.outerWidth());
  _set("salor_hotel.outerHeight", room.outerHeight());
  $('#rooms').append(room);
  from_input = create_dom_element('input', {type:'text',id:'show_booking_from', value: date_as_ymd(new Date(Date.parse(_get("salor_hotel.from_input"))))}, '', room);
  from_input.datepicker({
    onSelect: function (date, inst) {
      _set("salor_hotel.from_input",$('#show_booking_from').val());
      clear_bookings();
      render_booking_lines();
    }
  });
  $.each(_get("rooms.json").rooms,function (k,v) {
    var room = create_dom_element('div',{'class':"room-header",'id': 'room_header_' + v.room.id},v.room.name,$('#rooms'));
    css = {top: css.top, left: room.outerWidth() + css.left};
    draw_element(room,css,'offset');
    var room_column = create_dom_element('div',{'class':"room-column"},'',$('#rooms'));
    var col_css = {top: css.top + room.outerHeight() + tpad, left: css.left};
    draw_element(room_column,col_css,'offset');
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
  if (!$('#rooms').is(":visible")) {
    show_rooms_interface();
  }
  if (!_get("salor_hotel.from_input")) {
     var d = new Date();
     //_log(d);
    _set("salor_hotel.from_input",date_as_ymd(d));
  }
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
