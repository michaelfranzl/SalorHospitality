/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function get_table_show(table_id) {
  $('#order_info').html(i18n.connecting);
  $('#order_info_bottom').html(i18n.connecting);
  $.ajax({
    type: 'GET',
    url: '/tables/' + table_id,
    timeout: 7000,
    complete: function(data,status) {
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
            $('#order_info').html(i18n.server_error_short);
            break;
        }
      } else if (status == 'parsererror') {
        $('#order_info').html(i18n.server_error_short);
      } else {
        $('#order_info').html(i18n.server_error_short);        
      }
    }
  });
}

function update_tables(){
  $.ajax({
    url: '/tables',
    dataType: 'json',
    timeout: 15000,
    success: function(data) {
      resources.tb = data;
      render_tables();
    }
  });
}

function render_tables() {
  $('#tables').html('');
  $('#tablesselect_container').html('');
  $.each(resources.tb, function(k,v) {
    // determine color
    var bgcolor = null;
    if (v.auid) bgcolor = resources.u[v.auid].c;
    if (!v.e) bgcolor = 'black';
   
    //--------------------------
    // render spans for the move function
    var move_table_span = create_dom_element('span', {}, v.n, '#tablesselect_container');
    move_table_span.on('click', function() {
      route('tables', submit_json.model.table_id, 'move', {target_table_id:v.id});
    })
    move_table_span.addClass('option');
    if (typeof(bgcolor) == 'string') move_table_span.css('background-color', bgcolor);
    
    
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
    
    if (v.crid) {
      create_dom_element('span', {}, resources.customers.all[v.crid].n, table);
    } else if (v.auid) {
      create_dom_element('span', {}, resources.u[v.auid].n, table);
    }

    table.addClass(statusclass);
    table.addClass('table');
    table.css('left', left);
    table.css('top', top);
    table.css('width', width);
    table.css('height', height);
    
    if (typeof(bgcolor) == 'string') table.css('background-color', bgcolor);

    if (v.cp) {
      // confirmation pending
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (v.rf) {
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('cash_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (v.rw) {
      // requested waiter
      var cash_icon = create_dom_element('a',{},'',table);
      cash_icon.addClass('iconbutton');
      cash_icon.addClass('user_button'); 
      if (permissions.confirmation_user) {
        table.effect("pulsate", { times:2000 }, 3000);
      }
      table.css('color', 'black');
      table.css('background-color', 'white');
    }
    
    if (permissions.move_tables && settings.mobile_drag_and_drop || settings.workstation_drag_and_drop) {
      table.draggable({ stop: function() {
        update_table_coordinates(v.id)}
      })
      table.css('background-color', 'grey');      
    } else {
      if (v.e && !(!permissions.confirmation_user && (v.cp || v.rf || v.rw))) {
        // when confirmation_user is false, this user cannot view the order if any customer requests are pending
        _set('table',v,table);
        table.on('mousedown', function() {
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
    type: 'put',
    url: '/tables/' + id + '/update_coordinates',
    data: {left:left, top:top, mobile_drag_and_drop:settings.mobile_drag_and_drop},
    success: update_tables
  });
}