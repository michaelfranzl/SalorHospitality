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
      setTimeout ->
        emit 'salor_hotel.render_rooms',{}
      , 200


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
  _set 'possible_seasons',create_season_objects(resources.sn)
  db.transaction (tx) ->
    tx.executeSql 'DROP TABLE IF EXISTS surcharges;'
    tx.executeSql 'DROP TABLE IF EXISTS rooms;'
    tx.executeSql 'DROP TABLE IF EXISTS room_prices;'
    tx.executeSql 'DROP TABLE IF EXISTS seasons;'
    tx.executeSql 'CREATE TABLE surcharges (id INTEGER PRIMARY KEY, name STRING, season_id INTEGER, guest_type_id INTEGER, amount FLOAT, radio_select BOOLEAN, visible BOOLEAN, selected BOOLEAN);'
    tx.executeSql 'CREATE TABLE rooms (id INTEGER PRIMARY KEY, name STRING, room_type_id INTEGER);'
    tx.executeSql 'CREATE TABLE room_prices (id INTEGER PRIMARY KEY, guest_type_id INTEGER, room_type_id INTEGER, season_id INTEGER, base_price FLOAT);'
    tx.executeSql 'CREATE TABLE seasons (id INTEGER PRIMARY KEY, name STRING, from_date DATETIME, to_date DATETIME, duration INTEGER);'
    if $.isEmptyObject(resources)
      alert "The resources object is empty. Don't forget to generate the vendors cache."
    $.each resources.sc, (k,v) ->
      tx.executeSql 'INSERT INTO surcharges (id, name, season_id, guest_type_id, amount, radio_select, visible, selected) VALUES (?,?,?,?,?,?,?,?);', [k, v.n, v.sn, v.gt, v.a, v.r, v.v, v.s]
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
               submit_json.model.from_date = date
               window.booking_dates_changed()
               regenerate_all_multi_season_booking_items()
  }
  to_input = create_dom_element 'input', {type:'text',id:'booking_to'}, '', booking_tools
  to_input.datepicker {
    onSelect:(date, inst) ->
               id = submit_json.id
               submit_json.model.to_date = date
               window.booking_dates_changed()
               regenerate_all_multi_season_booking_items()
  }

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
    $(this).val result.name
    submit_json.model['customer_name'] = result.name
  customer_input.on 'keyup', ->
    submit_json.model['customer_name'] = $(this).val()
    
  rooms_button = create_dom_element 'span', {id: 'choose_room_container',class:'textbutton'},'',booking_tools
  rooms_select = create_dom_element 'select', {id:"choose_room"}, rooms_as_options(),rooms_button
  rooms_select.val room_id
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
  interim_invoice_link = create_dom_element 'span', {id:'booking_interim_invoice',class:'textbutton'}, i18n.interim_invoice, booking_tools
  assign_order_link = create_dom_element 'span', {id:'booking_assign_order',class:'textbutton'}, i18n.assign_order_to_booking, booking_tools
  payment_methods_link = create_dom_element 'span', {id:'add_payment_method_button',class:'textbutton'}, i18n.payment_method, booking_tools
  pay_link = create_dom_element 'span', {id:'booking_pay',class:'textbutton'}, i18n.pay, booking_tools
  cancel_link = create_dom_element 'span', {id:'booking_cancel',class:'textbutton'}, i18n.cancel, booking_tools
  cancel_link.on 'click', -> route 'rooms'
  delete_link = create_dom_element 'span', {id:'booking_delete',class:'textbutton'}, i18n.delete, booking_tools
  delete_link.on 'click', ->
    submit_json.model.hidden = true
    route 'rooms', room_id, 'send'
  
  render_guest_type_buttons()
  booking_items_container = create_dom_element 'div', {id:'booking_items_container'}, '', booking_form
  create_dom_element 'div', {id:'booking_items'}, '', booking_items_container
  payment_methods_container = create_dom_element 'div', {class:'payment_methods_container'}, '', booking_form
  create_dom_element 'table', {}, '', payment_methods_container
  create_dom_element 'div', {class:'booking_change'}, '', payment_methods_container


# Reads a time span from the submit_json object, writes back the duration. This called when the datepicker is changed.
window.booking_dates_changed = ->
  from = new Date(Date.parse(submit_json.model.from_date))
  to = new Date(Date.parse(submit_json.model.to_date))
  if (to - from) < 86400000
    to = new Date(from.getTime() + 86400000)
    $('#booking_to').val date_as_ymd(to)
    submit_json.model.to_date = date_as_ymd(to)
    
  duration = Math.floor((to.getTime() - from.getTime()) / 86400000)
  $('#booking_duration').val duration
  submit_json.model.duration = duration
  submit_json.model.covered_seasons = Season.applying_seasons(_get('possible_seasons'),from,to)
  
  
window.calculate_all_covered_seasons = ->
  $.each items_json, (k,v) ->
    from = new Date(Date.parse(items_json[k].from_date))
    to = new Date(Date.parse(items_json[k].to_date))
    items_json[k].covered_seasons = Season.applying_seasons(_get('possible_seasons'),from,to)
  
  
# =======================================================
# Private functions inside of a closure for encapsulation
# =======================================================

# Helper method used by "render_season_buttons". Just outputs options for changing the room.
rooms_as_options = ->
  str = ''
  $.each _get("rooms.json").rooms, (key,value) ->
    str += '<option value="'+value.room.id+'">' + value.room.name + '</option>'
  return str


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
      id = get_unique_booking_number('d') # d is for "dynamically generated"
      add_json_booking_item id, parseInt(k), 0, null
      setTimeout ->
        render_booking_items_from_json()
      , 200
  gtbutton = create_dom_element 'div', {class:'guest_type'}, i18n.common_surcharges, guest_types_container
  gtbutton.on 'click', ->
    gtbutton.effect 'highlight', {}, 500
    id = get_unique_booking_number('d') # d is for "dynamically generated"
    add_json_booking_item id, null, 0, null
    setTimeout ->
      render_booking_items_from_json()
    , 200


# This function adds objects to the items_json and submit_json objects so that they can be submitted to the server where they will be saved as a Booking.
add_json_booking_item = (booking_item_id, guest_type_id, season_index, parent_key) ->
  if booking_item_id.indexOf('x') != 0
    # this is a parent item
    covered_seasons = submit_json.model.covered_seasons
    season_id = covered_seasons[season_index].id
    duration = covered_seasons[season_index].duration
    from_date = covered_seasons[season_index].start
    to_date = covered_seasons[season_index].end
  else
    # this is a multi-season child item
    covered_seasons = items_json[parent_key].covered_seasons
    season_id = covered_seasons[season_index].id
    duration = covered_seasons[season_index].duration
    from_date = covered_seasons[season_index].start
    from_date_object = new Date Date.parse(from_date)
    from_date_object.setDate from_date_object.getDate() - 1
    from_date = date_as_ymd(from_date_object)
    to_date = covered_seasons[season_index].end
    covered_seasons = null
  
  create_json_record 'booking', {d:booking_item_id, guest_type_id:guest_type_id, season_id:season_id, duration:duration, parent_key:parent_key, from_date:from_date, to_date:to_date, covered_seasons:covered_seasons}
  if guest_type_id == null
    guest_type_query_string = 'guest_type_id IS NULL'
  else
    guest_type_query_string = 'guest_type_id = ' + guest_type_id
  update_base_price booking_item_id
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'SELECT id, name, amount, radio_select, visible, selected FROM surcharges WHERE ' + guest_type_query_string + ' AND season_id = ' + season_id + ';', [], (tx,res) ->
      for i in [0..res.rows.length-1]
        record = res.rows.item(i)
        radio_select = record.radio_select == 'true'
        visible = record.visible == 'true'
        selected = (record.selected == 'true') && (record.amount != 0)
        items_json[booking_item_id].surcharges[record.name] = {id:record.id, amount:record.amount, radio_select:radio_select, selected:selected, visible:visible}
        update_submit_json_surchageslist(booking_item_id)
      if season_index == 0
        # a new booking item has been added for the first covered season. Now delete + create (regenerate) all booking_items for the rest of the covered seasons.
        regenerate_multi_season_booking_items(booking_item_id)
        
regenerate_all_multi_season_booking_items = () ->
  # delete all child items. a preservation of existing child booking items would be too complex
  $.each items_json, (k,v) ->
    if k.indexOf('x') == 0 # child item
      $('#booking_item' + k).remove()
      set_json 'booking', k, 'hidden', true
    else # parent item
      $('#booking_item' + k).remove()
      items_json[k].has_children = false
      if v.date_locked == false
        from = new Date(Date.parse(submit_json.model.from_date))
        to = new Date(Date.parse(submit_json.model.to_date))
        items_json[k].covered_seasons = Season.applying_seasons(_get('possible_seasons'),from,to)
        
        duration = submit_json.model.covered_seasons[0].duration
        start = new Date(Date.parse(submit_json.model.covered_seasons[0].start))
        end = new Date(Date.parse(submit_json.model.covered_seasons[0].end))
        update_base_price(k)
        set_json 'booking', k, 'duration', duration
        set_json 'booking', k, 'from_date', date_as_ymd(start)
        set_json 'booking', k, 'to_date', date_as_ymd(end)
        set_json 'booking', k, 'season_id', submit_json.model.covered_seasons[0].id
    return true
  $.each items_json, (k,v) ->
    regenerate_multi_season_booking_items(k)
      
# this is a pure JSON operation
regenerate_multi_season_booking_items = (parent_booking_item_id) ->
  $.each items_json, (k,v) ->
    if k.indexOf('x') == 0 && v.parent_key == parent_booking_item_id && v.hidden != true
      # this is a child multiseason item, so just copy attributes from parent
      setTimeout ->
        copy_attributes parent_booking_item_id, k
      , 200 # warning: this timeout value must be smaller than the one below
    else if k.indexOf('x') != 0 && v.has_children == false # this parent item doesn't have children, so we generate one child per covered season
      items_json[k].has_children = true
      $.each v.covered_seasons, (i,covered_season) ->
        # create a child item for all covered seasons
        if i == 0
          return true # the parent item always belongs to the first covered season, so we break the loop
        id = get_unique_booking_number('x') # x is for multi-season booking_items
        add_json_booking_item id, v.guest_type_id, i, k
        
        setTimeout ->
          copy_attributes k, id
        , 200 # warning: this timeout value must be smaller than the one below
  setTimeout ->
    render_booking_items_from_json()
    update_booking_totals()
  , 250
        

copy_attributes = (from_id, to_id) ->
  set_json 'booking', to_id, 'count', items_json[from_id].count
  set_json 'booking', to_id, 'parent_key', from_id
  set_json 'booking', to_id, 'booking_item_id', items_json[from_id].id
  set_json 'booking', to_id, 'hidden', items_json[from_id].hidden
  set_json 'booking', to_id, 'date_locked', items_json[from_id].date_locked
  $.each items_json[from_id].surcharges, (k,v) ->
    items_json[to_id].surcharges[k].selected = v.selected
    update_submit_json_surchageslist(to_id)
    return true
      
# Called when a room is changed, when a new booking item is added (see "add_json_booking_item"), and when "update_json_booking_items" is called. It gets the current base room price from the local DB and saves it into the workspace json objects.
update_base_price = (k) ->
  db = _get 'db'
  db.transaction (tx) ->
    tx.executeSql 'SELECT id, base_price FROM room_prices WHERE room_type_id = ' + submit_json.model.room_type_id + ' AND guest_type_id = ' + items_json[k].guest_type_id + ' AND season_id = ' + items_json[k].season_id + ';', [], (tx,res) ->
      if res.rows.length == 0
        base_price = 0
      else
        base_price = res.rows.item(0).base_price
      set_json 'booking', k, 'base_price', base_price


# This function loops over all items in items_json and updates the surcharge prices.
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
      tx.executeSql 'SELECT id, name, amount, radio_select, visible, selected FROM surcharges WHERE ' + guest_type_query_string + ' AND season_id = ' + submit_json.model.season_id + ';', [], (tx,res) ->
        for i in [0..res.rows.length-1]
          record = res.rows.item(i)
          items_json[k].surcharges[record.name].id = record.id
          items_json[k].surcharges[record.name].amount = record.amount
          items_json[k].surcharges[record.name].radio_select = record.radio_select
        update_submit_json_surchageslist k

        


# Adds a new row of buttons to the booking form. The source is an item which is already in the local json storage.
render_booking_item = (booking_item_id) ->
  if items_json[booking_item_id].hidden == true
    return true
  surcharge_headers = _get 'surcharge_headers'
  if items_json[booking_item_id].guest_type_id == null
    # a dynamically generated booking_item_id with s at the beginning means "special". Special means that the generated row/surchargeitem does not represent a guest_type, but is simply a collection of surcharges.
    guest_type_name = i18n.common_surcharges
    surcharge_headers = surcharge_headers.guest_type_null
  else
    guest_type_id = items_json[booking_item_id].guest_type_id
    guest_type_name = resources.gt[guest_type_id].n
    surcharge_headers = surcharge_headers.guest_type_set
  if items_json[booking_item_id].parent_key != null
    add_class = 'semitransparent'
    
  label = guest_type_name + " <small>(" + resources.sn[items_json[booking_item_id].season_id].n + ")</small>"
  booking_item_row = create_dom_element 'div', {class:'booking_item ' + add_class, id:'booking_item'+booking_item_id}, '', '#booking_items'
  create_dom_element 'div', {class:'surcharge_col'}, label, booking_item_row
  render_booking_item_count booking_item_id
  
  from_date_col = create_dom_element 'div', {class:'surcharge_col booking_item_datelock',id:'booking_item_'+booking_item_id+'_from_date_col',booking_item_id:booking_item_id}, '',booking_item_row
  from_date_col_input = create_dom_element 'input', {id:'booking_item_'+booking_item_id+'_from_date', class:'booking_item_from_date'}, '', from_date_col
  from_date_col_input.val items_json[booking_item_id].from_date
  
  to_date_col = create_dom_element 'div', {class:'surcharge_col booking_item_datelock',id:'booking_item_'+booking_item_id+'_to_date_col',booking_item_id:booking_item_id}, '',booking_item_row
  to_date_col_input = create_dom_element 'input', {id:'booking_item_'+booking_item_id+'_to_date', class:'booking_item_to_date'}, '', to_date_col
  to_date_col_input.val items_json[booking_item_id].to_date
  
  duration_col = create_dom_element 'div', {class:'surcharge_col',id:'booking_item_'+booking_item_id+'_duration_col',booking_item_id:booking_item_id}, items_json[booking_item_id].duration, booking_item_row
  
  if items_json[booking_item_id].date_locked == true
    from_date_col.addClass 'selected'
    to_date_col.addClass 'selected'

  if booking_item_id.indexOf('x') != 0
    from_date_col_input.datepicker {
      onSelect:(date, inst) ->
        if Date.parse(date) > Date.parse(items_json[booking_item_id].to_date)
          items_json[booking_item_id].to_date = date
        set_json 'booking', $(from_date_col).attr('booking_item_id'), 'from_date', date
        from_date_col_input.val items_json[booking_item_id].from_date
        change_date_for_booking_item(booking_item_id)
    }
    to_date_col_input.datepicker {
      onSelect:(date, inst) ->
        if Date.parse(date) < Date.parse(items_json[booking_item_id].from_date)
          items_json[booking_item_id].from_date = date
        set_json 'booking', $(to_date_col).attr('booking_item_id'), 'to_date', date
        to_date_col_input.val items_json[booking_item_id].to_date
        change_date_for_booking_item(booking_item_id)
    }

    
  for header in surcharge_headers
    if items_json[booking_item_id].surcharges.hasOwnProperty(header)
      surcharge_col = create_dom_element 'div', {class:'surcharge_col surcharge_col_'+booking_item_id,id:'surcharge_col_'+header+'_'+booking_item_id}, header, booking_item_row
      (=>
        h = header
        bid = booking_item_id
        surcharge_col.on 'click', ->
          if bid.indexOf('x') == 0
            return true
          el = $(this).children('input')
          if items_json[el.attr('booking_item_id')].surcharges[el.attr('surcharge_name')].amount != 0
            if el.attr 'checked'
              el.attr 'checked', false
              $(this).removeClass 'selected'
            else
              el.attr 'checked', true
              $(this).effect 'highlight', {}, 500
              $(this).addClass 'selected'
            save_selected_input_state el, booking_item_id, h
            update_booking_totals()
          else
            el.attr 'checked', false
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
      if items_json[booking_item_id].surcharges[header].selected && items_json[booking_item_id].surcharges[header].amount != 0
        input_tag.attr 'checked', true
        input_tag.parent().addClass 'selected'
  create_dom_element 'div', {class:'surcharge_col booking_item_total',id:'booking_item_'+booking_item_id+'_total'}, '', booking_item_row
  delete_col = create_dom_element 'div', {class:'surcharge_col booking_item_delete',id:'booking_item_'+booking_item_id+'_delete'}, '&nbsp;',booking_item_row
  delete_col.on 'click', ->
    delete_booking_item(booking_item_id)
  update_booking_totals()

# changes the date_lock status and updates all child items
change_date_for_booking_item = (booking_item_id) ->
  if booking_item_id.indexOf('x') == 0
    return # ignore child items, only change parent items
  set_json 'booking', booking_item_id, 'date_locked', true
  $('#booking_item_'+booking_item_id+'_datelock').addClass 'selected'
  $.each items_json, (k,v) ->
    if v.parent_key == booking_item_id
      items_json[k].date_locked = true
    else
      from = new Date(Date.parse(v.from_date))
      to = new Date(Date.parse(v.to_date))
      if (to - from) < 86400000
        to = new Date(from.getTime() + 86400000)
        set_json 'booking', booking_item_id, 'to_date', date_as_ymd(to)
        $("#booking_item_" + booking_item_id + "_to_date").val date_as_ymd(to)
      items_json[k].covered_seasons = Season.applying_seasons(_get('possible_seasons'),from,to)
      set_json 'booking', k, 'duration', items_json[k].covered_seasons[0].duration
  render_booking_items_from_json()
  regenerate_all_multi_season_booking_items()

# deletes a booking item from the DOM and sets 'hidden' in the json sources.
delete_booking_item = (booking_item_id) ->
  if booking_item_id.indexOf('x') != 0
    $('#booking_item' + booking_item_id).remove()
    set_json 'booking', booking_item_id, 'hidden', true
    regenerate_all_multi_season_booking_items()
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
  regenerate_multi_season_booking_items(booking_item_id)


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
    if k.indexOf('x') == 0
      # Skip child items, these will be rendered directly below the parent items
      return true
    render_booking_item k
    $.each items_json, (i,j) ->
      if j.parent_key == k
        render_booking_item i



render_booking_item_count = (booking_item_id) ->
  count_input_col = create_dom_element 'div', {class:'surcharge_col'}, count_input, '#booking_item' + booking_item_id
  count_input = create_dom_element 'input', {type:'text', id:'booking_item_'+booking_item_id+'_count', class:'booking_item_count', value:items_json[booking_item_id].count}, '', count_input_col
  if booking_item_id.indexOf('x') == 0
    return true
  make_keyboardable count_input, '', `function(){ change_booking_item_count(booking_item_id)}`, 'num'
  count_input.select()
  count_input.on 'keyup', ->
    change_booking_item_count booking_item_id



change_booking_item_count = (booking_item_id) ->
  count = $('#booking_item_' + booking_item_id + '_count').val()
  set_json 'booking', booking_item_id, 'count', count
  items_json[booking_item_id].count = parseInt(count)
  regenerate_multi_season_booking_items(booking_item_id)



update_booking_item_total = (booking_item_id) ->
  total = items_json[booking_item_id].base_price
  $.each items_json[booking_item_id].surcharges, (k,v) ->
    if v.selected == true
      total += v.amount
    return true
  count = items_json[booking_item_id].count
  total *= count
  $('#booking_item_' + booking_item_id + '_total').html number_to_currency total
  return total



update_booking_totals = ->
  total = 0
  $.each items_json, (k,v) ->
    if v.hidden == true
      return true
    total += update_booking_item_total(k) * items_json[k].duration
    true
  $('#booking_total').html number_to_currency total
  booking_id = submit_json.id
  subtotal = total + submit_json.totals[booking_id].booking_orders
  $('#booking_subtotal').html number_to_currency subtotal
  submit_json.totals[booking_id].model = total
  return total


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
