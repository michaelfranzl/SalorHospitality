# document ready code
$ ->
  connect 'salor_hotel.refresh_db', 'ajax.update_resources.success', window.update_salor_hotel_db
  connect 'salor_hotel.refresh_rooms', 'ajax.update_resources.success', window.render_rooms
  if window.openDatabase
    _set 'db', openDatabase('SalorHotel', '1.0', 'salor_hotel_database', 200000)
  # hotel_add_price_form_button()
  hotel_add_room_container()
  initialize_json()


# Updates the local DB from JSON objects delivered by rails. Hooked into update_resources of the main app.
window.update_salor_hotel_db = ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'DROP TABLE IF EXISTS surcharges;'
    tx.executeSql 'DROP TABLE IF EXISTS rooms;'
    tx.executeSql 'DROP TABLE IF EXISTS room_prices;'
    tx.executeSql 'CREATE TABLE surcharges (id INTEGER PRIMARY KEY, name STRING, season_id INTEGER, guest_type_id INTEGER, amount FLOAT, radio_select BOOLEAN);'
    tx.executeSql 'CREATE TABLE rooms (id INTEGER PRIMARY KEY, name STRING, room_type_id INTEGER);'
    tx.executeSql 'CREATE TABLE room_prices (id INTEGER PRIMARY KEY, guest_type_id INTEGER, room_type_id INTEGER, base_price FLOAT);'
    $.each resources.sc, (k,v) ->
      tx.executeSql 'INSERT INTO surcharges (id, name, season_id, guest_type_id, amount, radio_select) VALUES (?,?,?,?,?,?);', [k, v.n, v.sn, v.gt, v.a, v.r]
    $.each resources.r, (k,v) ->
      tx.executeSql 'INSERT INTO rooms (id, name, room_type_id) VALUES (?,?,?);', [k, v.n, v.rt]
    $.each resources.rp, (k,v) ->
      tx.executeSql 'INSERT INTO room_prices (id, guest_type_id, room_type_id, base_price) VALUES (?,?,?,?);', [k, v.gt, v.rt, v.p]


# Updates the visual room buttons. Hooked into update_resources of the main app.
window.render_rooms = ->
  $('#rooms').html ''
  $.each resources.r, (k,v) ->
    room = $ document.createElement 'div'
    room.addClass 'room'
    room.html v.n
    room.on 'click', ->
      display_hotel_price_form k
      submit_json.booking.room_id = k
      submit_json.booking.room_type_id = v.rt
    $('#rooms').append room

# Initializes the main attributes of the submit_json object.
initialize_json = ->
  submit_json['booking'] = {}
  submit_json.booking['season_id'] = null
  submit_json.booking['room_id'] = null
  submit_json.booking['room_type_id'] = null
  submit_json['booking_items'] = {}
  items_json['booking'] = {}
  #_set 'reservation_items_json', {}

# Called by document.ready. Serves as a replacement for HTML templates.
hotel_add_room_container = ->
  room_container = $ document.createElement 'div'
  room_container.attr 'id', 'rooms'
  $('#main').append room_container

# Called when clicking on a room. Serves as a replacement for HTML templates.
display_hotel_price_form = ->
  hotel_price_form = $ document.createElement 'div'
  hotel_price_form.attr 'id', 'hotel_price_form'
  $('#main').append hotel_price_form
  surcharges_container = $ document.createElement 'div'
  surcharges_container.attr 'id', 'surcharges'
  hotel_price_form.append surcharges_container
  surcharges_headers = $ document.createElement 'div'
  surcharges_headers.attr 'id', 'surcharges_headers'
  surcharges_container.append surcharges_headers
  surcharges_rows_container = $ document.createElement 'div'
  surcharges_rows_container.attr 'id', 'booking_items'
  surcharges_container.append surcharges_rows_container
  render_season_buttons()
  render_guest_type_buttons()
  render_surcharge_header()


# Called by display_hotel_price_form. Just displays buttons for seasons, adds an onclick function and highlights the current season.
render_season_buttons = ->
  season_container = create_dom_element 'div', {id:'seasons'}, '', '#hotel_price_form'
  $.each resources.sn, (id,v) ->
    sbutton = create_dom_element 'div', {class:'season',id:'season_'+id}, v.n, season_container
    sbutton.on 'click', ->
      select_season(id)
    if v.c == true
      sbutton.addClass 'selected'
      submit_json.booking.season_id = id

select_season = (id) ->
  submit_json.booking.season_id = id 
  sbutton = $('#season_' + id)
  $('.season').removeClass 'selected'
  sbutton.addClass 'selected'
  $.each items_json.booking, (k,v) ->
    surcharge_recalculate k


# Called by display_hotel_price_form. Just displays buttons for guest_types, adds an onclick function.
render_guest_type_buttons = ->
  guest_types_container = $ document.createElement 'div'
  guest_types_container.attr 'id', 'guest_types'
  $('#hotel_price_form').append guest_types_container
  $.each resources.gt, (k,v) ->
    gtbutton = create_dom_element 'div', {class:'guest_type'}, v.n, guest_types_container
    gtbutton.on 'click', -> render_surcharge_row k, v.n

# This gets unique names of surcharges from the DB. Those names will be rendered as headers for the price calcualtion popup, and will be stored as an array in the jQuery "surcharge_headers" variable. This variable is used later on in the function "render_surcharge_row" to align the corresponding surcharge radio/checkboxes beneath the proper headings. The reason for the alignment is that not all GuestTypes have an identical set of surcharges, so we build a common superset.
render_surcharge_header= ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql "SELECT DISTINCT name FROM surcharges WHERE guest_type_id IS NOT NULL;", [], (tx,res) ->
      header = create_dom_element 'div', {class:'header'}, 'i18n GuestType', '#surcharges_headers'
      surcharge_headers = []
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_headers.push record.name
        header = create_dom_element 'div', {class:'header'}, record.name, '#surcharges_headers'
      _set 'surcharge_headers', surcharge_headers


# This function renders HTML input tags for the selected GuestType beneath the proper headers, as well as an text field for the quantity of the GuestType. It also adds the base RoomPrice for the selected GuestType when no Surcharge radio/checkbox tags are selected. If any radio/checkbox Surcharge tags are selected, onclick events will add the Surcharge amount to the base RoomPrice. This function also manages the items_json and submit_json objects so that they can be submitted to the server where they will be saved as a Booking.
render_surcharge_row = (guest_type_id, guest_type_name) ->
  booking_item_id = get_unique_surcharge_row_number()
  booking_item = create_dom_element 'div', {class:'booking_item', id:'booking_item'+booking_item_id}, '', '#booking_items'
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'SELECT id, name, amount, radio_select FROM surcharges WHERE guest_type_id = ' + guest_type_id + ' AND season_id = ' + submit_json.booking.season_id + ';', [], (tx,res) ->
      # We can't use the DB results directly to render the input elements, since the headers dictate the exact appearance. Therefore we build an object called surcharge_guest_object that will be matched later to the surcharge_header object.
      surcharge_guest_object = {}
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_guest_object[record.name] = {id:record.id, amount:record.amount, radio_select:record.radio_select}
      surcharge_headers = _get 'surcharge_headers'
      create_dom_element 'div', {class:'surcharge_col'}, guest_type_name, booking_item
      for header in surcharge_headers
        if surcharge_guest_object.hasOwnProperty(header)
          id = surcharge_guest_object[header].id
#base_price = 
          surcharge_col = create_dom_element 'div', {class:'surcharge_col surcharge_col_'+booking_item_id}, '', booking_item
          if surcharge_guest_object[header].radio_select
            input_tag = create_dom_element 'input', {type:'radio', name:'radio_surcharge_'+booking_item_id, id:'surcharge_'+id, booking_item_id:booking_item_id, surcharge_id:id}, '', surcharge_col
          else
            input_tag = create_dom_element 'input', {type:'checkbox', name:'checkbox_surcharge_'+id, id:'surcharge_'+id, booking_item_id:booking_item_id, surcharge_id:id}, '', surcharge_col
          input_tag.on 'change', ->
            surcharge_recalculate(booking_item_id)

  db.transaction (tx) ->
    tx.executeSql 'SELECT id, base_price FROM room_prices WHERE room_type_id = ' + submit_json.booking.room_type_id + ' AND guest_type_id = ' + guest_type_id + ';', [], (tx,res) ->
      base_price = res.rows.item(0).base_price
      create_dom_element 'div', {class:'surcharge_col', id:'booking_item_'+booking_item_id+'_total'}, base_price, booking_item
      items_json.booking[booking_item_id] = {count:1, guest_type_id:guest_type_id, base_price:base_price}
      submit_json.booking_items[booking_item_id] = {count:1, guest_type_id:guest_type_id}


surcharge_recalculate = (booking_item_id) ->
  input_tags = $('input:checked[booking_item_id="' + booking_item_id + '"]')
  items_json.booking[booking_item_id]['surcharges'] = {}
  submit_json.booking_items[booking_item_id]['surcharges'] = []
  surcharge_total = 0
  for input_tag in input_tags
    surcharge_id = $(input_tag).attr 'surcharge_id'
    amount = resources.sc[surcharge_id].a
    surcharge_total += amount
    items_json.booking[booking_item_id].surcharges[surcharge_id] = {amount:amount}
    submit_json.booking_items[booking_item_id].surcharges.push surcharge_id
  base_price = items_json.booking[booking_item_id].base_price
  $('#booking_item_' + booking_item_id + '_total').html base_price + surcharge_total



          



sqlErrorHandler = (e) ->
  alert 'An SQL error occurred.'

create_dom_element = (tag,attrs,content,append_to) ->
  element = $ document.createElement tag
  $.each attrs, (k,v) ->
    element.attr k, v
  element.html content
  if append_to != ''
    $(append_to).append element
  return element

get_unique_surcharge_row_number = ->
  number = _get 'unique_surcharge_row_number'
  if typeof(number) == 'undefined'
    _set 'unique_surcharge_row_number', 1
    return 1
  else
    number += 1
    _set 'unique_surcharge_row_number', number
    return number
