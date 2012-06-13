
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
  console.log('called');
  if (!booking) {
    console.log('bookin is nil');
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

window.render_booking_lines = function () {
  $('.booking-line').remove();
  var num_rooms = _get("rooms.json").keys.length;
  var width = ('190px');
  var css = {width: width}
  var now = new Date(Date.parse($('#show_booking_from').val()))
  var i = 1
  var rooms_bookings = [];
  while (i < 32) {
    x = 1
    var d = new Date(now.getFullYear(),now.getMonth(), now.getDate() + i - 1)
    var r = create_dom_element('div', {class: 'room-header left booking-line', id: 'booking_date_' + i }, d.getDate(), $('#rooms'));
    r.css(css)
    while (x <= num_rooms + 1) {
      booked = false
      var room_id = x;
      if (_get("rooms.json").keys[x-1]) {
        if (!rooms_bookings[x]) {
          rooms_bookings[x] = _get("rooms.json").get_bookings(x);
        }
        bookings = rooms_bookings[x];
        var active_booking = {};
        if (bookings) {
          $.each(bookings, function (b) {
            if (is_booked(bookings[b],d)) {
              active_booking = bookings[b];
              booked = true
            }
          });
        }
        if (booked) {
          r = create_dom_element('div', {class: 'room-header booking-line room-header-occupied', id: 'booking_date_' + i + '_' + x}, '&nbsp;', $('#rooms'));
          r.attr('booking_id',active_booking.id);
          r.on('click',function () {
            var x = $(this).attr('room_id');
            route('booking', x,'show',{'booking_id': $(this).attr('booking_id')});
            submit_json.model.room_id = x;
            submit_json.model.room_type_id = _get("rooms.json").rooms[x].room_type.id;
          });
        } else {
          r = create_dom_element('div', {class: 'room-header booking-line', id: 'booking_date_' + i + '_' + x}, '&nbsp;', $('#rooms'));
          r.on('click',function () {
            var x = $(this).attr('room_id');
            route('room',x);
            submit_json.model.room_id = x;
            submit_json.model.room_type_id = _get("rooms.json").rooms[x].room_type.id;
          });
        }
        r.attr('date',d);
        r.attr('room_id',x);
        r.css(css);
        
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
  var num_rooms = _get("rooms.json").keys.length;
  $('#rooms').css({'width': num_rooms * 200 + 250 + 'px'})
  width = (parseInt($('#rooms').parent().width()) / (num_rooms + 2)) + 'px';
  css = {width: '190px'}
  room = $(document.createElement('div'));
  room.addClass('room-header');
  room.css(css);
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
    room.css(css);
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
