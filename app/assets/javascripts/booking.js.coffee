# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# document ready code
$ ->
  connect 'salor_hotel.refresh_db', 'ajax.update_resources.success', window.update_salor_hotel_db
  connect 'salor_hotel.receive_rooms_db', 'ajax.rooms_index.success', window.receive_rooms_db
  connect 'salor_hotel.refresh_rooms', 'salor_hotel.render_rooms', window.render_rooms
  connect 'salor_hotel.booking_send','send.booking', window.update_room_bookings
  connect 'salor_hotel.add_button_menu_rendered','button_menu.rendered', add_payment_method_buttons
  if window.openDatabase
    _set 'db', openDatabase('SalorHotel', '1.0', 'salor_hotel_database', 200000)
  create_dom_element 'div', {id:'rooms'}, '', '#rooms_container'
  if not _get("salor_hotel.from_input")
    _set("salor_hotel.from_input",date_as_ymd(new Date()))
  fetch_rooms()
  $(window).on 'resize', ->
    if $('#rooms').is(":visible")
      emit 'salor_hotel.render_rooms',{}


# Functions accessible from window
# ================================

window.add_payment_method_buttons = (event) ->
  packet = event.packet
  if packet.attr('id').indexOf('payment_methods_container') != -1 and $('.booking_form').is(":visible")
    add_menu_button packet, create_dom_element('div',{'id': 'add_pm_button',class:'add-button', model_id: packet.attr('model_id')},'',''), ->
      add_payment_method($(this).attr('model_id'))
      
# Updates the local DB from JSON objects delivered by the Server.
window.update_salor_hotel_db = ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'DROP TABLE IF EXISTS surcharges;'
    tx.executeSql 'DROP TABLE IF EXISTS rooms;'
    tx.executeSql 'DROP TABLE IF EXISTS room_prices;'
    tx.executeSql 'DROP TABLE IF EXISTS seasons;'
    tx.executeSql 'CREATE TABLE surcharges (id INTEGER PRIMARY KEY, name STRING, season_id INTEGER, guest_type_id INTEGER, amount FLOAT, radio_select BOOLEAN);'
    tx.executeSql 'CREATE TABLE rooms (id INTEGER PRIMARY KEY, name STRING, room_type_id INTEGER);'
    tx.executeSql 'CREATE TABLE room_prices (id INTEGER PRIMARY KEY, guest_type_id INTEGER, room_type_id INTEGER, season_id INTEGER, base_price FLOAT);'
    tx.executeSql 'CREATE TABLE seasons (id INTEGER PRIMARY KEY, name STRING, from_date DATETIME, to_date DATETIME, duration INTEGER);'
    $.each resources.sc, (k,v) ->
      tx.executeSql 'INSERT INTO surcharges (id, name, season_id, guest_type_id, amount, radio_select) VALUES (?,?,?,?,?,?);', [k, v.n, v.sn, v.gt, v.a, v.r]
    $.each resources.r, (k,v) ->
      tx.executeSql 'INSERT INTO rooms (id, name, room_type_id) VALUES (?,?,?);', [k, v.n, v.rt]
    $.each resources.rp, (k,v) ->
      tx.executeSql 'INSERT INTO room_prices (id, guest_type_id, room_type_id, season_id, base_price) VALUES (?,?,?,?,?);', [k, v.gt, v.rt, v.sn, v.p]
    $.each resources.sn, (k,v) ->
      tx.executeSql 'INSERT INTO seasons (id, name, from_date, to_date, duration) VALUES (?,?,?,?,?);', [k, v.n, v.f, v.t, v.d]

# Called when clicking on a room. Displays the booking form dynamically
window.display_booking_form = (room_id) ->
  render_surcharge_header()
  booking_form = create_dom_element 'div', {class:'booking_form'}, '', '#main'
  booking_tools = create_dom_element 'div', {id:'booking_tools'}, '', booking_form
  booking_totals = create_dom_element 'div', {id:'booking_totals'}, '', booking_form
  from_input = create_dom_element 'input', {type:'text',id:'booking_from'}, '', booking_tools
  from_input.datepicker {
    onSelect:(date, inst) ->
               id = submit_json.id
               submit_json.model['from_date'] = date
               window.update_booking_duration()
  }
  to_input = create_dom_element 'input', {type:'text',id:'booking_to'}, '', booking_tools
  to_input.datepicker {
    onSelect:(date, inst) ->
               id = submit_json.id
               submit_json.model['to_date'] = date
               window.calculate_booking_duration()
  }
  duration_input = create_dom_element 'input', {type:'text',id:'booking_duration',value:1}, '', booking_tools
  duration_input.on 'click', -> $(this).select()
  duration_input.on 'keyup', -> set_booking_duration()

  if submit_json.model['customer_name'] == ''
    customer_name_default = i18n.customer
  else
    customer_name_default = submit_json.model['customer_name']
  
  customer_input = create_dom_element 'input', {type:'text',id:'booking_customer',value:customer_name_default}, '', booking_tools
  customer_input.on 'focus', ->
    if $(this).val() == ''
      $(this).val(customer_name_default)
    if $(this).val() == 'i18n_customer'
      $(this).val("")
  auto_completable customer_input, resources.customers, {map:true, field: 'name'}, (result) ->
    console.log result
    $(this).val result.name
    submit_json.model['customer_name'] = result.name
  customer_input.on 'keyup', ->
    submit_json.model['customer_name'] = $(this).val()
    
  rooms_button = create_dom_element 'span', {id: 'choose_room_container',class:'textbutton'},'',booking_tools
  rooms_select = create_dom_element 'select', {id:"choose_room"}, rooms_as_options(),rooms_button
  rooms_select.on 'change', ->
    id = $(this).val()
    submit_json.model.room_id = id
    submit_json.model.room_type_id = resources.r[id].rt
    $.each items_json, (k,v) ->
      update_base_price k
    setTimeout ->
      update_booking_totals()
    , 200
    
  submit_link = create_dom_element 'span', {id:'booking_submit',class:'textbutton'}, i18n.save, booking_tools
  submit_link.on 'click', -> route 'rooms', room_id, 'send'
  payment_methods_link = create_dom_element 'span', {id:'add_payment_method_button',class:'textbutton'}, i18n.payment_method, booking_tools
  pay_link = create_dom_element 'span', {id:'booking_pay',class:'textbutton'}, i18n.pay, booking_tools
  pay_link.on 'click', -> route 'rooms', room_id, 'pay'
  cancel_link = create_dom_element 'span', {id:'booking_cancel',class:'textbutton'}, i18n.cancel, booking_tools
  cancel_link.on 'click', -> route 'rooms'
  render_season_buttons()
  render_guest_type_buttons()
  booking_items_container = create_dom_element 'div', {id:'booking_items_container'}, '', booking_form
  create_dom_element 'div', {id:'booking_items'}, '', booking_items_container
  payment_methods_container = create_dom_element 'div', {class:'payment_methods_container'}, '', booking_form
  create_dom_element 'div', {class:'booking_change'}, '', payment_methods_container


# Reads a time span from the submit_json object, writes back the duration, and updates the currently displayed booking totals. This called when the datepicker is changed. The datepicker changes from and to in the submit_json object all by itself.
window.calculate_booking_duration = ->
  from = Date.parse(submit_json.model.from_date)
  to = Date.parse(submit_json.model.to_date)
  duration = Math.floor((to - from) / 86400000)
  $('#booking_duration').val duration
  submit_json.model.duration = duration
  update_booking_totals()

# =======================================================
# Private functions inside of a closure for encapsulation
# =======================================================

# Called as onchange event of the duration input field.
set_booking_duration = ->
  duration = $('#booking_duration').val()
  submit_json.model.duration = duration
  update_booking_totals()


# Helper method used by "render_season_buttons". Just outputs options for changing the room.
rooms_as_options = ->
  str = ''
  $.each _get("rooms.json").rooms, (key,value) ->
    str += '<option value="'+value.room.id+'">' + value.room.name + '</option>'
  return str


# Called by display_booking_form. Just displays buttons for seasons, adds an onclick function and highlights the current season. Also adds a select box for changing the room.
render_season_buttons = ->
  season_container = create_dom_element 'div', {id:'seasons'}, '', '.booking_form'
  $.each resources.sn, (id,v) ->
    sbutton = create_dom_element 'div', {class:'season',id:'season_'+id}, v.n, season_container
    sbutton.on 'click', ->
      window.change_season(id)
    if v.c == true
      sbutton.addClass 'selected'
      submit_json.model.season_id = id


# Called when clicking on a season button.
window.change_season = (id) ->
  submit_json.model.season_id = id
  sbutton = $('#season_' + id)
  $('.season').removeClass 'selected'
  sbutton.effect 'highlight', {}, 500
  sbutton.addClass 'selected'
  update_json_booking_items()
  setTimeout ->
    window.render_booking_items_from_json()
  , 200


# This gets unique names of surcharges from the DB. Those names will be rendered as headers for the booking form, and will be stored as an array in the jQuery "surcharge_headers" variable. This variable is used later in the function "render_surcharge_row" to align the corresponding surcharge radio/checkboxes beneath the proper headings. The reason for the alignment is that not all GuestTypes have an identical set of surcharges, so we build a common superset.
render_surcharge_header= ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql "SELECT DISTINCT name FROM surcharges WHERE guest_type_id IS NOT NULL;", [], (tx,res) ->
      surcharge_headers = _get 'surcharge_headers'
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_headers.guest_type_set.push record.name
      _set 'surcharge_headers', surcharge_headers
   db.transaction (tx) ->
    tx.executeSql "SELECT DISTINCT name FROM surcharges WHERE guest_type_id IS NULL;", [], (tx,res) ->
      surcharge_headers = _get 'surcharge_headers'
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        surcharge_headers.guest_type_null.push record.name
      _set 'surcharge_headers', surcharge_headers



# Called by display_booking_form. Just displays buttons for guest_types, adds an onclick function.
render_guest_type_buttons = ->
  guest_types_container = create_dom_element 'div', {id:'guest_types'}, '', '.booking_form'
  $.each resources.gt, (k,v) ->
    gtbutton = create_dom_element 'div', {class:'guest_type'}, v.n, guest_types_container
    gtbutton.on 'click', ->
      gtbutton.effect 'highlight', {}, 500
      id = get_unique_booking_number('d')
      add_json_booking_item id, parseInt(k)
      setTimeout ->
        render_booking_item(id)
      , 50
  gtbutton = create_dom_element 'div', {class:'guest_type'}, i18n.common_surcharges, guest_types_container
  gtbutton.on 'click', ->
    gtbutton.effect 'highlight', {}, 500
    id = get_unique_booking_number('s')
    add_json_booking_item id, null
    setTimeout ->
      render_booking_item(id)
    , 50


# This function renders HTML input tags for the selected GuestType beneath the proper headers, as well as an text field for the quantity of the GuestType. The data source is items_json. It also adds the base RoomPrice for the selected GuestType when no Surcharge radio/checkbox tags are selected. If any radio/checkbox Surcharge tags are selected, onclick events will add the Surcharge amount to the base RoomPrice. This function also manages the items_json and submit_json objects so that they can be submitted to the server where they will be saved as a Booking.
add_json_booking_item = (booking_item_id, guest_type_id) ->
  create_json_record 'booking', {guest_type_id:guest_type_id, d:booking_item_id}
  if guest_type_id == null
    guest_type_query_string = 'guest_type_id IS NULL'
    update_base_price booking_item_id
  else
    guest_type_query_string = 'guest_type_id = ' + guest_type_id
    update_base_price booking_item_id
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'SELECT id, name, amount, radio_select FROM surcharges WHERE ' + guest_type_query_string + ' AND season_id = ' + submit_json.model.season_id + ';', [], (tx,res) ->
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        radio_select = record.radio_select == 'true'
        items_json[booking_item_id].surcharges[record.name] = {id:record.id, amount:record.amount, radio_select:radio_select, selected:false}


# Called when a room is changed (see "render_season_buttons"), when a new booking item is added (see "add_json_booking_item"), and when "update_json_booking_items" is called. It gets the current base room price from the local DB and saves it into the workspace json objects.
update_base_price = (k) ->
    db = _get 'db'
    db.transaction (tx) ->
      debug "Updating base price for item " + k + ", for room_type_id " + submit_json.model.room_type_id
      tx.executeSql 'SELECT id, base_price FROM room_prices WHERE room_type_id = ' + submit_json.model.room_type_id + ' AND guest_type_id = ' + items_json[k].guest_type_id + ' AND season_id = ' + submit_json.model.season_id + ';', [], (tx,res) ->
        if res.rows.length == 0
          base_price = 0
        else
          base_price = res.rows.item(0).base_price
        set_json 'booking', k, 'base_price', base_price


# Called from "change_season". This function loops over all items in items_json and updates the surcharge prices.
update_json_booking_items = ->
  $.each items_json, (k,v) ->
    guest_type_id = items_json[k].guest_type_id
    debug 'udate_json_booking_items: guest_type_id = ' + guest_type_id
    if guest_type_id == 0 || guest_type_id == null
      guest_type_query_string = 'guest_type_id IS NULL'
    else
      guest_type_query_string = 'guest_type_id = ' + guest_type_id
    update_base_price k
    db = _get 'db'
    db.transaction (tx) ->
      tx.executeSql 'SELECT id, name, amount, radio_select FROM surcharges WHERE ' + guest_type_query_string + ' AND season_id = ' + submit_json.model.season_id + ';', [], (tx,res) ->
        for i in [0..res.rows.length-1]
          record = res.rows.item(i)
          items_json[k].surcharges[record.name].id = record.id
          items_json[k].surcharges[record.name].amount = record.amount
          items_json[k].surcharges[record.name].radio_select = record.radio_select
        update_submit_json_surchageslist k

        


# Adds a new row of buttons to the booking form. The source is an item which is already in the local json storage.
render_booking_item = (booking_item_id) ->
  surcharge_headers = _get 'surcharge_headers'
  if booking_item_id.indexOf('s') == 0
    # a dynamically generated booking_item_id with s at the beginning means "special". Special means that the generated row/surchargeitem does not represent a guest_type, but is simply a collection of surcharges.
    guest_type_name = i18n.common_surcharges
    surcharge_headers = surcharge_headers.guest_type_null
  else
    guest_type_id = items_json[booking_item_id].guest_type_id
    guest_type_name = resources.gt[guest_type_id].n
    surcharge_headers = surcharge_headers.guest_type_set
  booking_item_row = create_dom_element 'div', {class:'booking_item', id:'booking_item'+booking_item_id}, '', '#booking_items'
  create_dom_element 'div', {class:'surcharge_col'}, guest_type_name, booking_item_row
  render_booking_item_count booking_item_id
  for header in surcharge_headers
    if items_json[booking_item_id].surcharges.hasOwnProperty(header)
      surcharge_col = create_dom_element 'div', {class:'surcharge_col surcharge_col_'+booking_item_id,id:'surcharge_col_'+header+'_'+booking_item_id}, header, booking_item_row
      (=>
        h = header
        surcharge_col.on 'click', ->
          el = $(this).children('input')
          if el.attr 'checked'
            el.attr 'checked', false
            $(this).removeClass 'selected'
          else
            el.attr 'checked', true
            $(this).effect 'highlight', {}, 500
            $(this).addClass 'selected'
          save_selected_input_state el, booking_item_id, h
          update_booking_totals()
      )()
      if items_json[booking_item_id].surcharges[header].radio_select
        input_tag = create_dom_element 'input', {type:'radio', name:'radio_surcharge_'+booking_item_id, booking_item_id:booking_item_id, surcharge_name:header}, '', surcharge_col
      else
        input_tag = create_dom_element 'input', {type:'checkbox', name:'checkbox_surcharge_'+booking_item_id, booking_item_id:booking_item_id, surcharge_name:header}, '', surcharge_col
      (=>
        h = header
        input_tag.on 'change', ->
          save_selected_input_state this, booking_item_id, h
          update_booking_totals()
        )()
      if items_json[booking_item_id].surcharges[header].selected
        input_tag.attr 'checked', true
        input_tag.parent().addClass 'selected'
  create_dom_element 'div', {class:'surcharge_col booking_item_total',id:'booking_item_'+booking_item_id+'_total'}, '', booking_item_row
  delete_col = create_dom_element 'div', {class:'surcharge_col booking_item_delete',id:'booking_item_'+booking_item_id+'_delete'}, '&nbsp;', booking_item_row
  delete_col.on 'click', ->
    delete_booking_item(booking_item_id)
  update_booking_totals()

# deletes a booking item from the DOM and sets 'hidden' in the json sources.
delete_booking_item = (booking_item_id) ->
  $('#booking_item' + booking_item_id).remove()
  set_json 'booking', booking_item_id, 'hidden', true
  update_booking_totals()

# The DIVs which represent surcharges actually contain hidden HTML input elements like checkbox and radio box. On change of these inputs, their state will be read and saved into the json objects.
save_selected_input_state = (element, booking_item_id, surcharge_name) ->
  if $(element).attr('type') == 'radio'
    $.each items_json[booking_item_id].surcharges, (k,v) ->
      if v.radio_select
        items_json[booking_item_id].surcharges[k].selected = false
        $('#surcharge_col_' + k + '_' + booking_item_id).removeClass 'selected'
      true
  if $(element).is(':checked')
    items_json[booking_item_id].surcharges[surcharge_name].selected = true
    element.parent().addClass 'selected'
  else
    items_json[booking_item_id].surcharges[surcharge_name].selected = false
    element.parent().removeClass 'selected'
  update_submit_json_surchageslist booking_item_id


# Copy data over into submit_son from items_json, add surcharge IDs to array, which will be interpreted by the Server.
update_submit_json_surchageslist = (booking_item_id) ->
  set_json 'booking', booking_item_id, 'surchargeslist', [0]
  $.each items_json[booking_item_id].surcharges, (k,v) ->
    if v.selected
      submit_json.items[booking_item_id].surchargeslist.push v.id


# render all booking items which are in the items_json object to the DOM
window.render_booking_items_from_json = ->
  $('#booking_items').html ''
  $.each items_json, (k,v) ->
    render_booking_item k



render_booking_item_count = (booking_item_id) ->
  count_input_col = create_dom_element 'div', {class:'surcharge_col'}, count_input, '#booking_item' + booking_item_id
  count_input = create_dom_element 'input', {type:'text', id:'booking_item_'+booking_item_id+'_count', class:'booking_item_count', value:items_json[booking_item_id].count}, '', count_input_col
  make_keyboardable count_input, '', `function(){ change_booking_item_count(booking_item_id)}`, 'num'
  count_input.select()
  count_input.on 'keyup', ->
    change_booking_item_count booking_item_id



change_booking_item_count = (booking_item_id) ->
  count = $('#booking_item_' + booking_item_id + '_count').val()
  set_json 'booking', booking_item_id, 'count', count
  #items_json[booking_item_id].count = count
  update_booking_totals()



booking_item_total = (booking_item_id) ->
  total = items_json[booking_item_id].base_price
  $.each items_json[booking_item_id].surcharges, (k,v) ->
    if v.selected == true
      total += v.amount
    true
  count = items_json[booking_item_id].count
  total *= count
  $('#booking_item_' + booking_item_id + '_total').html number_to_currency total
  total



update_booking_totals = ->
  total = 0
  $.each items_json, (k,v) ->
    if v.hidden == true
      return true
    total += booking_item_total k
    true
  total *= submit_json.model.duration
  $('#booking_total').html number_to_currency total
  booking_id = submit_json.id
  $('#booking_subtotal').html number_to_currency total + submit_json.totals[booking_id].booking_orders
  submit_json.totals[booking_id].model = total
  total


make_keyboardable = (element,open_on,accepted,layout) ->
  element.keyboard {
    openOn:open_on
    accepted: accepted
    layout:layout
  }
  element.on 'click', ->
    element.getkeyboard().reveal()
    $('.ui-keyboard-input').select()


sqlErrorHandler = (e) ->
  alert 'An SQL error occurred.'



get_unique_booking_number = (prefix) ->
  number = _get 'unique_surcharge_row_number'
  if typeof(number) == 'undefined'
    number = 1
  else
    number += 1
  _set 'unique_surcharge_row_number', number
  return prefix + number
