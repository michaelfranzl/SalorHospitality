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
    tx.executeSql 'CREATE TABLE surcharges (id INTEGER PRIMARY KEY, name STRING, season_id INTEGER, guest_type_id INTEGER, amount FLOAT, radio_select BOOLEAN);'
    tx.executeSql 'CREATE TABLE rooms (id INTEGER PRIMARY KEY, name STRING, room_type_id INTEGER);'
    $.each resources.sc, (k,v) ->
      tx.executeSql 'INSERT INTO surcharges (id, name, season_id, guest_type_id, amount, radio_select) VALUES (?,?,?,?,?,?);', [k, v.n, v.sn, v.gt, v.a, v.r]
    $.each resources.r, (k,v) ->
      tx.executeSql 'INSERT INTO rooms (id, name, room_type_id) VALUES (?,?,?);', [k, v.n, v.rt]


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
    $('#rooms').append room

# Initializes the main attributes of the submit_json object.
initialize_json = ->
  submit_json['booking'] = {}
  submit_json.booking['season_id'] = null
  submit_json.booking['room_id'] = null
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
  surcharges_rows_container.attr 'id', 'surcharge_rows'
  surcharges_container.append surcharges_rows_container
  render_season_buttons()
  render_guest_type_buttons()
  render_surcharge_header()


# Called by display_hotel_price_form. Just displays buttons for seasons, adds an onclick function and highlights the current season.
render_season_buttons = ->
  season_container = $ document.createElement 'div'
  season_container.attr 'id', 'seasons'
  $('#hotel_price_form').append season_container
  $.each resources.sn, (k,v) ->
    sbutton = $ document.createElement 'div'
    sbutton.addClass 'season'
    sbutton.on 'click', ->
      submit_json.booking.season_id = k
      $('.season').removeClass 'selected'
      $(this).addClass 'selected'
    if v.c == true
      # select current season
      sbutton.addClass 'selected'
      submit_json.booking.season_id = k
    sbutton.html v.n
    season_container.append sbutton


# Called by display_hotel_price_form. Just displays buttons for guest_types, adds an onclick function.
render_guest_type_buttons = ->
  guest_types_container = $ document.createElement 'div'
  guest_types_container.attr 'id', 'guest_types'
  $('#hotel_price_form').append guest_types_container
  $.each resources.gt, (k,v) ->
    gtbutton = $ document.createElement 'div'
    gtbutton.addClass 'guest_type'
    gtbutton.on 'click', -> render_surcharge_row k
    gtbutton.html v.n
    guest_types_container.append gtbutton

# This gets unique names of surcharges from the DB. Those names will be rendered as headers for the price calcualtion popup, and will be stored as an array in the jQuery "surcharge_headers" variable. This variable is used later on in the function "render_surcharge_row" to align the corresponding surcharge radio/checkboxes beneath the proper headings. The reason for the alignment is that not all GuestTypes have an identical set of surcharges, so we build a common superset.
render_surcharge_header= ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql "SELECT DISTINCT name FROM surcharges WHERE guest_type_id IS NOT NULL;", [], (tx,res) ->
      surcharge_headers = []
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_headers.push record.name
        header = $ document.createElement 'div'
        header.addClass 'header'
        header.html record.name
        $('#surcharges_headers').append header
      _set 'surcharge_headers', surcharge_headers


# This function renders HTML input tags for the selected GuestType beneath the proper headers, as well as an text field for the quantity of the GuestType. It also adds the base RoomPrice for the selected GuestType when no Surcharge radio/checkbox tags are selected. If any radio/checkbox Surcharge tags are selected, onclick events will add the Surcharge amount to the base RoomPrice. This function also manages the items_json and submit_json objects so that they can be submitted to the server where they will be saved as a Booking.
render_surcharge_row = (guest_type_id) ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'SELECT id, name, amount, radio_select FROM surcharges WHERE guest_type_id = ' + guest_type_id + ' AND season_id = ' + submit_json.booking.season_id + ';', [], (tx,res) ->
      surcharge_guest_object = {}
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_guest_object[record.name] = {id:record.id, amount:record.amount, radio_select:record.radio_select}
      surcharge_headers = _get 'surcharge_headers'
      number = get_unique_surcharge_row_number()
      create_dom_element 'div', {class:'surcharge_row',id:'surcharge_row_'+number}, '', '#surcharge_rows'
      for header in surcharge_headers
        if surcharge_guest_object.hasOwnProperty(header)
          id = surcharge_guest_object[header].id
          column = create_dom_element 'div', {class:'surcharge_col', id:'surcharge_col_'+number}, '', '#surcharge_row_' + number
          if surcharge_guest_object[header].radio_select
            radio = create_dom_element 'input', {type:'radio', name:'radio_surcharge_'+number, id:'surcharge_'+id}, '', column
          else
            checkbox = create_dom_element 'input', {type:'checkbox', name:'checkbox_surcharge_'+id, id:'surcharge_'+id}, '', column
            items_json.booking['dynamic_'+number] = {count:1, guest_type_id:guest_type_id, surcharges:[]}
          



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
