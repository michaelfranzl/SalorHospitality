/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function get_table_show(table_id) {
  if (user_shift_ended == true) {
    alert(i18n.your_shift_has_ended);
  }
  $('#order_info').html(i18n.connecting);
  $('#order_info_bottom').html(i18n.connecting);
  $.ajax({
    type: 'GET',
    url: '/tables/' + table_id,
    timeout: 15000,
    cache: false,
    complete: function(data,status) {
      unloadify_order_buttons();
      if (status == 'timeout') {
        if ( get_table_show_retry ) {
          $('#order_info').html(i18n.no_connection_retrying);
          $('#order_info_bottom').html(i18n.no_connection_retrying);
          window.setTimeout(function() {
            get_table_show(table_id)
          }, 1000);
        }
      } else if (status == 'success') {
        offline_mode = false;
        $('#order_submit_button').html('');
        render_items();
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            $('#order_info').html(i18n.no_connection);
            $('#order_info_bottom').html(i18n.no_connection);
            if ( get_table_show_retry ) {
              window.setTimeout(function() {
                get_table_show(table_id)
              }, 1000);
            }
            break;
          case 4:
            send_email('readyState 4 error in get_table_show', table_id);
            $('#order_info').html(i18n.server_error_short);
            break;
        }
      } else if (status == 'parsererror') {
        send_email('ajax parsererror in get_table_show', table_id);
        $('#order_info').html(i18n.server_error_short);
      } else {
        send_email('other ajax error in get_table_show', table_id);
        $('#order_info').html(i18n.server_error_short);        
      }
    }
  });
}

function update_tables() {
  $.ajax({
    type: 'GET',
    url: '/tables',
    dataType: 'json',
    timeout: 20000,
    cache: false,
    success: function(data) {
      resources.tb = data;
      render_tables();
    },
    complete: function(data, status) {
      if (status == 'timeout' ) {
        //send_email('update_tables(): timeout', '');
        //alert(i18n.server_not_responded);
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            //send_email('update_tables(): No connection error', '');
            break;
          case 4:
            send_email('update_tables(): Server Error', '');
            alert(i18n.server_error);
            break;
          default:
            send_email('update_tables(): unknown ajax "readyState" for status "complete".', data.readyState);
        };   
      }
    }
  });
}

function render_tables() {
  $('#tables').html('');
  $('#tablesselect_container').html('');
  $.each(resources.tb, function(k,v) {
    
    var bgcolor = null;
    var fcolor = null;
   
    //--------------------------
    // render spans for the move function. This is a pop-up DIV on the order screen.
    var move_table_span = create_dom_element('span', {}, v.n, '#tablesselect_container');
    move_table_span.on('click', function() {
      route('tables', submit_json.model.table_id, 'move', {target_table_id:v.id});
    })
    move_table_span.addClass('option');
    //--------------------------
    
    
    // ------------------------
    // render divs for the actual tables
    var mobile_mode = settings.mobile || settings.mobile_drag_and_drop;
    var left = mobile_mode ? v.lm : v.l;
    var top = mobile_mode  ? v.tm : v.t;
    var width = mobile_mode ? v.wm : v.w;
    var height = mobile_mode ? v.hm : v.h;
    if (v.r) {
      var tmp = width;
      width = height;
      height = tmp;
    }
         
    var statusclass = v.auid ? 'occupied' : 'vacant';
    var table = create_dom_element('div',{id:'table'+v.id,ontouchstart:'javascript:enable_audio();'}, v.n, '#tables');
    
    // add labels to table
    if (v.acrid) {
      // active customer id
      var active_customer_name = '';
      if (typeof resources.customers.all[v.acrid] != 'undefined') {
        active_customer_name = resources.customers.all[v.acrid].n;
      } else {
        active_customer_name = '?';
      }
      create_dom_element('span', {}, active_customer_name, table);
      
    } else if (v.no) {
      // note
      create_dom_element('span', {}, v.no, table);
      
    } else if (v.auid) {
      // active user id
      var username = '';
      if (typeof resources.u[v.auid] != 'undefined' ) {
        username = resources.u[v.auid].n;
      } else {
        username = '?';
      }
      create_dom_element('span', {}, username, table);
    }

    table.addClass(statusclass);
    table.addClass('table');
    table.css('left', left);
    table.css('top', top);
    table.css('width', width);
    table.css('height', height);
    
    
    //--------------------------
    // determine color

    if (!v.e)
      bgcolor = 'black'; // e means enabled
      
    if (v.crid != null) {
      bgcolor = 'white';
      fcolor = 'black';
    }
    
    if (v.auid) {
      bgcolor = resources.u[v.auid].c; // auid means active user id
      fcolor = 'white';
    }


    if (v.cp && permissions.confirmation_user) {
      table.effect("pulsate", { times:2000 }, 3000);
      bgcolor = 'white';
      fcolor = 'black';
      // cp means confirmation pending
    }
    
    if (v.rf) {
      // rf means request finish
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('cash_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
    }
    
    if (v.rw) {
      // rw means requested waiter
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('user_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
    }
    
    table.css('background-color', bgcolor);
    table.css('color', fcolor);
    move_table_span.css('background-color', bgcolor);
    move_table_span.css('color', fcolor);
    //--------------------------
    
    if (permissions.move_tables && settings.mobile_drag_and_drop || settings.workstation_drag_and_drop) {
      table.draggable({ stop: function() {
        update_table_coordinates(v.id)}
      })
      table.css('background-color', 'grey');      
    } else {
      if (v.e && !(!permissions.confirmation_user && (v.cp || v.rf || v.rw))) {
        // when confirmation_user is false, this user cannot view the order if any customer requests are pending
        _set('table',v,table);
        table.on('click', function() {
          var v = _get('table',$(this));
          route('table',v.id);
        });
      }
    }
  });
}

function update_table_coordinates(id) {
  var table = $('#table' + id);
  var left = table.position().left;
  var top = table.position().top; 
  $.ajax({
    type: 'PUT',
    url: '/tables/' + id + '/update_coordinates',
    data: {left:left, top:top, mobile_drag_and_drop:settings.mobile_drag_and_drop},
    success: update_tables
  });
}