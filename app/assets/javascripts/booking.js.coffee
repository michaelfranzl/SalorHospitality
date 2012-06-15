# document ready code
$ ->
  connect 'salor_hotel.refresh_db', 'ajax.update_resources.success', window.update_salor_hotel_db
  connect 'salor_hotel.receive_rooms_db', 'ajax.rooms_index.success', window.receive_rooms_db
  connect 'salor_hotel.refresh_rooms', 'salor_hotel.render_rooms', window.render_rooms
  connect 'salor_hotel.booking_send','send.booking', window.update_room_bookings
  if window.openDatabase
    _set 'db', openDatabase('SalorHotel', '1.0', 'salor_hotel_database', 200000)
  # hotel_add_price_form_button()
  create_dom_element 'div', {id:'rooms'}, '', '#rooms_container'
  fetch_rooms()
  $(window).on 'resize', ->
    if $('#rooms').is(":visible")
      emit 'salor_hotel.render_rooms',{}


# Updates the local DB from JSON objects delivered by rails. Hooked into update_resources of the main app.


window.update_salor_hotel_db = ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'DROP TABLE IF EXISTS surcharges;'
    tx.executeSql 'DROP TABLE IF EXISTS rooms;'
    tx.executeSql 'DROP TABLE IF EXISTS room_prices;'
    tx.executeSql 'CREATE TABLE surcharges (id INTEGER PRIMARY KEY, name STRING, season_id INTEGER, guest_type_id INTEGER, amount FLOAT, radio_select BOOLEAN);'
    tx.executeSql 'CREATE TABLE rooms (id INTEGER PRIMARY KEY, name STRING, room_type_id INTEGER);'
    tx.executeSql 'CREATE TABLE room_prices (id INTEGER PRIMARY KEY, guest_type_id INTEGER, room_type_id INTEGER, season_id INTEGER, base_price FLOAT);'
    $.each resources.sc, (k,v) ->
      tx.executeSql 'INSERT INTO surcharges (id, name, season_id, guest_type_id, amount, radio_select) VALUES (?,?,?,?,?,?);', [k, v.n, v.sn, v.gt, v.a, v.r]
    $.each resources.r, (k,v) ->
      tx.executeSql 'INSERT INTO rooms (id, name, room_type_id) VALUES (?,?,?);', [k, v.n, v.rt]
    $.each resources.rp, (k,v) ->
      tx.executeSql 'INSERT INTO room_prices (id, guest_type_id, room_type_id, season_id, base_price) VALUES (?,?,?,?,?);', [k, v.gt, v.rt, v.sn, v.p]



# Called when clicking on a room. Serves as a replacement for HTML templates.
window.display_booking_form = (room_id) ->
  render_surcharge_header()
  booking_form = create_dom_element 'div', {class:'booking_form'}, '', '#main'
  booking_tools = create_dom_element 'div', {id:'booking_tools'}, '', booking_form
  booking_totals = create_dom_element 'div', {id:'booking_totals'}, '', booking_form
  from_input = create_dom_element 'input', {type:'text',id:'booking_from'}, '', booking_tools
  from_input.datepicker {
    onSelect:(date, inst) ->
               id = submit_json.id
               submit_json.model['from'] = date
  }
  to_input = create_dom_element 'input', {type:'text',id:'booking_to'}, '', booking_tools
  to_input.datepicker {
    onSelect:(date, inst) ->
               id = submit_json.id
               submit_json.model['to'] = date
               window.calculate_booking_duration()
  }
  duration_input = create_dom_element 'input', {type:'text',id:'booking_duration',value:1}, '', booking_tools
  duration_input.on 'click', -> $(this).select()
  duration_input.on 'keyup', -> set_booking_duration()
  
  `var customer_name_default = (submit_json.model['customer_name'] == '') ? 'i18n_customer' : submit_json.model['customer_name'];`
  
  customer_input = create_dom_element 'input', {type:'text',id:'booking_customer',value:customer_name_default}, '', booking_tools
  customer_input.on 'focus', ->
    if $(this).val() == '' 
      $(this).val(customer_name_default)
    if $(this).val() == 'i18n_customer'
      $(this).val("")
  auto_completable customer_input,resources.customers,{map:true,field: 'name'}, (result) ->
    console.log(result)
    $(this).val(result.name)
    submit_json.model['customer_name'] = result.name
  #customer_input.on 'keyup'
  
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
  #add_category_button i18n.customers, {id:'customers_category_button', handlers:{'mouseup':`function(){show_customers(booking_form)}`}, bgcolor:"50,50,50", bgimage:'/assets/category_customer.png', append_to:booking_tools}
  payment_methods_container = create_dom_element 'div', {class:'payment_methods_container'}, '', booking_form
  create_dom_element 'div', {class:'booking_change'}, '', payment_methods_container

window.initialize_booking_form = ->
  id = get_unique_booking_number('s')
  add_json_booking_item id, null
  setTimeout ->
    window.render_booking_items_from_json()
  , 150

window.calculate_booking_duration = ->
  from = Date.parse(submit_json.model.from)
  to = Date.parse(submit_json.model.to)
  duration = Math.floor((to - from) / 86400000)
  $('#booking_duration').val duration
  submit_json.model.duration = duration
  update_booking_totals()

set_booking_duration = ->
  duration = $('#booking_duration').val()
  submit_json.model.duration = duration
  update_booking_totals()

  

# Called by display_booking_form. Just displays buttons for seasons, adds an onclick function and highlights the current season.
render_season_buttons = ->
  season_container = create_dom_element 'div', {id:'seasons'}, '', '.booking_form'
  $.each resources.sn, (id,v) ->
    sbutton = create_dom_element 'div', {class:'season',id:'season_'+id}, v.n, season_container
    sbutton.on 'click', ->
      window.change_season(id)
    if v.c == true
      sbutton.addClass 'selected'
      submit_json.model.season_id = id

window.change_season = (id) ->
  submit_json.model.season_id = id
  sbutton = $('#season_' + id)
  $('.season').removeClass 'selected'
  sbutton.effect 'highlight', {}, 500
  sbutton.addClass 'selected'
  update_json_booking_items()
  setTimeout ->
    window.render_booking_items_from_json()
  , 150


# This gets unique names of surcharges from the DB. Those names will be rendered as headers for the price calcualtion popup, and will be stored as an array in the jQuery "surcharge_headers" variable. This variable is used later on in the function "render_surcharge_row" to align the corresponding surcharge radio/checkboxes beneath the proper headings. The reason for the alignment is that not all GuestTypes have an identical set of surcharges, so we build a common superset.
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



# We can't use the DB results directly to render the input elements, since the headers dictate actually the exact appearance. Not all UserTypes have an identical set of Surcharges. Therefore we build an object called surcharge_guest_object that will be matched later to the surcharge_header object via it's key. We can avoid running several SQL queries with this pre-rendered object.


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
        items_json[booking_item_id].surcharges[record.name] = {id:record.id, amount:record.amount, radio_select:record.radio_select, selected:false}


  
update_base_price = (k) ->
    db = _get 'db'
    db.transaction (tx) ->
      tx.executeSql 'SELECT id, base_price FROM room_prices WHERE room_type_id = ' + submit_json.model.room_type_id + ' AND guest_type_id = ' + items_json[k].guest_type_id + ' AND season_id = ' + submit_json.model.season_id + ';', [], (tx,res) ->
        if res.rows.length == 0
          base_price = 0
        else
          base_price = res.rows.item(0).base_price
        set_json 'booking', k, 'base_price', base_price


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

        



render_booking_item = (booking_item_id) ->
  surcharge_headers = _get 'surcharge_headers'
  if booking_item_id.indexOf('s')== 0
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


delete_booking_item = (booking_item_id) ->
  $('#booking_item' + booking_item_id).remove()
  set_json 'booking', booking_item_id, 'hidden', true


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


update_submit_json_surchageslist = (booking_item_id) ->
  # copy stuff over into submit_son from items_json, add ids to array
  set_json 'booking', booking_item_id, 'surchargeslist', [0]
  $.each items_json[booking_item_id].surcharges, (k,v) ->
    if v.selected
      submit_json.items[booking_item_id].surchargeslist.push v.id
    



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
