
window.receive_rooms_db = function (event) {
  var data = event.packet;
  var bookings = [];
  data.get_bookings = function (room_index) {
    room_id = this.keys[room_index - 1]
    return this.rooms[room_id + ''].bookings;
  };
  _set("rooms.json",data);
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
window.update_bookings_for_room = function (id,bookings) {
  resources.r[id].bks = []
  $.each(bookings, function (b) {
    var booking = {f: b['from'], t:b['to'], cid: b['customer_id'], sid: b['season_id'], d:b['duration'] };
    resources.r[id].bks.push(booking);
  } );
  
  
}
window.is_booked = function (booking,date) {
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
  var owidth = _get("salor_hotel.outerWidth") + lpad;
  var oheight = _get("salor_hotel.outerHeight") + tpad;
  var widget_height = oheight * nights;
  var booking_class;
  var offset = $('#rooms').offset();
  var new_offset = {top: offset.top + (y * oheight + oheight) - 25, left: offset.left + (owidth * x) + 5};
  
  if (_get('salor_hotel.booking.odd'+ x) == false) {
    booking_class = 'odd';
    _set('salor_hotel.booking.odd'+ x,true);
  } else {
    console.log("Setting to even for", booking);
    booking_class = 'even';
    _set('salor_hotel.booking.odd'+ x,false);
  }
  if (booking.customer_name == '') {
    booking.customer_name = 'i18n_unamed';
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
  booking_widget.offset(new_offset);
  booking_widget.css({height: widget_height});
  booking_widget.on('click',function () {
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

window.render_booking_lines = function () {
  $('.booking-line').remove();
  var num_rooms = _get("rooms.json").keys.length;
  var now = new Date(Date.parse($('#show_booking_from').val()))
  var i = 1
  var rooms_bookings = [];
  var offset = $('#rooms').offset();
  var tpad = _get("salor_hotel.tpad");
  var lpad = _get("salor_hotel.lpad");
  var owidth = _get("salor_hotel.outerWidth") + lpad;
  var oheight = _get("salor_hotel.outerHeight") + tpad;
  var css = {top: offset.top, left: offset.left};
  
  while (i < 32) {
    x = 1
    css = {top: offset.top + (i * oheight), left: offset.left + lpad};
    var d = new Date(now.getFullYear(),now.getMonth(), now.getDate() + i - 1)
    var r = create_dom_element('div', {class: 'room-date-column left booking-line', id: 'booking_date_' + i }, d.getDate(), $('#rooms'));
    r.offset(css)
    while (x <= num_rooms + 1) {
      var room_id = x;
      if (_get("rooms.json").keys[x-1]) {
        if (!rooms_bookings[x]) {
          rooms_bookings[x] = _get("rooms.json").get_bookings(x);
        }
        bookings = rooms_bookings[x];
        if (bookings) {
          $.each(bookings, function (b) {
            if (is_booked(bookings[b],d)) {
              draw_booking(d,i,bookings[b]);
            }
          });
        }
      }
      x++ ;
    }
    $("#rooms").append("<br class='booking-line' />");;
    i++;
  }
}
// updates the visual room buttons. Hooked into update_resources of the main app.
window.render_rooms = function (event) {
  if (_get("rooms.rendered")) {
    console.log("Rooms already rendered.");
    return;
  }
  $('#rooms').html('');
  var offset = $('#rooms').offset();
  var tpad = 0;
  var lpad = 0;
  _set("salor_hotel.tpad",tpad);
  _set("salor_hotel.lpad",lpad);
  var num_rooms = _get("rooms.json").keys.length;
  $('#rooms').css({'width': num_rooms * 200 + 275 + 'px'})
  width = (parseInt($('#rooms').parent().width()) / (num_rooms + 2)) + 'px';
  css = {top: offset.top + tpad, left: offset.left + lpad}
  var room = create_dom_element('div',{'class':"room-header", id: 'room_date_select'},'',$('#rooms'));
  room.offset(css);
  _set("salor_hotel.outerWidth", room.outerWidth());
  _set("salor_hotel.outerHeight", room.outerHeight());
  $('#rooms').append(room);
  from_input = create_dom_element('input', {type:'text',id:'show_booking_from', value: date_as_ymd(new Date())}, '', room);
  from_input.datepicker({
    onSelect: function (date, inst) {
    console.log('date selected');
    render_booking_lines();
    }
  });
  $.each(_get("rooms.json").rooms,function (k,v) {
    var room = create_dom_element('div',{'class':"room-header"},v.room.name,$('#rooms'));
    css = {top: css.top, left: room.outerWidth() + css.left + lpad};
    room.offset(css);
    var room_column = create_dom_element('div',{'class':"room-column"},'',$('#rooms'));
    var col_css = {top: css.top + room.outerHeight() + tpad, left: css.left};
    room_column.offset(col_css);
    var height = (room.outerHeight() + tpad) * 31;
    room_column.css({height: height});
    room.on('click',function () {
      route('room', k);
      submit_json.model.room_id = k;
      submit_json.model.room_type_id = v.room_type.id;
    });
  });
  _set('rooms.rendered',true);
  $('#rooms').append("<br />");
  render_booking_lines()
}
