/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function update_item_lists() {
  if (permissions.see_item_notifications_vendor_preparation || permissions.see_item_notifications_vendor_delivery) {
    // permitting any of the vendor notification overrides all of the user notifications
    $.ajax({
      url: '/items/list',
      dataType: 'json',
      data: {type:'vendor'},
      success: function(data) {
        resources.notifications_vendor = data;
        notification_alerts('vendor');
        if (permissions.see_item_notifications_vendor_preparation) render_item_list('interactive', 'vendor', 'preparation');
        if (permissions.see_item_notifications_vendor_delivery)    render_item_list('interactive', 'vendor', 'delivery');
        if (settings.workstation && permissions.see_item_notifications_static) {
          if (permissions.confirmation_user) render_item_list('static', 'vendor', 'confirmation');
          if (permissions.see_item_notifications_vendor_preparation) render_item_list('static', 'vendor', 'preparation');
          if (permissions.see_item_notifications_vendor_delivery) render_item_list('static', 'vendor', 'delivery');
        }
      },
      timeout: 15000 
    });
  } else if (permissions.see_item_notifications_user_preparation || permissions.see_item_notifications_user_delivery) {
    $.ajax({
      url: '/items/list',
      dataType: 'json',
      data: {type:'user'},
      success: function(data) {
        resources.notifications_user = data;
        notification_alerts('user');
        if (permissions.see_item_notifications_user_preparation) render_item_list('interactive', 'user', 'preparation');
        if (permissions.see_item_notifications_user_delivery)    render_item_list('interactive', 'user', 'delivery');
        if (settings.workstation && permissions.see_item_notifications_static) {
          if (permissions.confirmation_user) render_item_list('static', 'user', 'confirmation');
          if (permissions.see_item_notifications_user_preparation) render_item_list('static', 'user', 'preparation');
          if (permissions.see_item_notifications_user_delivery) render_item_list('static', 'user', 'delivery');
        }
      },
      timeout: 15000 
    });
  }
}

function notification_alerts(model) {    
  if (model == 'user') {
    var delivery_notification_user_count = Object.keys(resources.notifications_user.delivery).length;
    var prepraration_notification_user_count = Object.keys(resources.notifications_user.preparation).length;
    var total_count = delivery_notification_user_count + prepraration_notification_user_count;
  } else if (model == 'vendor') {
    var delivery_notification_vendor_count = Object.keys(resources.notifications_vendor.delivery).length;
    var prepraration_notification_vendor_count = Object.keys(resources.notifications_vendor.preparation).length;
    var total_count = delivery_notification_vendor_count + prepraration_notification_vendor_count;
  }
  $('.items_notifications_button').html(total_count);
  $('.mobile_last_invoices_button').html(total_count);
  if (total_count > 0) {
    if (permissions.audio && audio_enabled) {
      alert_audio();
    }
    audio_enabled = true;
  }
}

function change_item_status(id,status) {
  $.ajax({
    type: 'POST',
    url: '/items/change_status?id=' + id + '&status=' + status
  });
}

function render_item_list(type, model, scope) {
  if (typeof resources.tb == 'undefined')
    return;  // this happens after update_resources() has erased resources['tb'] and no update_tables() has yet happened. TODO: move the tables hash out of resources.
    
  if (type == 'interactive') {
    var list_container = $('#list_interactive_' + scope);
    list_container.html('');
    $.each(resources['notifications_' + model][scope], function(k,v) {
      
      if (typeof resources.tb[v.tid] == 'undefined')
        return;
      
      var table_name = resources.tb[v.tid].n;
      var user_id = v[scope + '_uid'];
      if (user_id != null) {
        var user_name = resources.u[user_id].n;
      }
      
      var item_container = create_dom_element('div',{id:'item_list_' + scope + '_'+ v.id},'',list_container);
      item_container.addClass('item_list');
      var hours = v.t.substring(0,2);
      var minutes = v.t.substring(3,5);
      var seconds = v.t.substring(6,8);

      var t1 = new Date();
      t1.setHours(hours);
      t1.setMinutes(minutes);
      t1.setSeconds(seconds);

      var t2 = new Date();
      var difference = t2-t1;
      var color_intensity = Math.floor(difference/upper_delivery_time_limit * 255);
      color_intensity += 1;
      color_intensity = (color_intensity < 0) ? 255 : color_intensity;
      var color = 'rgb(' + color_intensity + ', 60, 60)';
      var waiting_time = Math.floor(difference/60000);
      var confirmed = v[scope + '_c'] != null
      if (!confirmed) {
        var unconfirmed_element = create_dom_element('div',{id:'item_list_'+scope+'_'+v.id+'_unconfirmed'}, table_name + ' | ' + v.c + " × " + v.l, item_container);
        unconfirmed_element.css('background-color', color);
        unconfirmed_element.addClass('unconfirmed');
        unconfirmed_element.on('click', function() {
          item_list_confirm(v.id, model, scope)
        });
      }
      var confirmed_element = create_dom_element('div',{id:'item_list_'+scope+'_'+v.id+'_confirmed', style:'display: none;'}, '', item_container);
      confirmed_element.addClass('confirmed');
      confirmed_element.css('background-color', color);
      if (confirmed) confirmed_element.show();
      if (v.s) var image = create_dom_element('img',{src:'/items/' + v.id +'.svg'},'',confirmed_element);
      var table = create_dom_element('table',{},'',confirmed_element);
      var row = create_dom_element('tr',{},'',table);
      var cell_tablename = create_dom_element('td',{},table_name,row);

      switch(scope) {
        case 'confirmation':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          break;
        case 'preparation':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          var cell_reference_count_2 = create_dom_element('td', {}, v.confirmation_c, row);
          cell_reference_count_2.addClass('reference_count');
          break;
        case 'delivery':
          var cell_reference_count_1 = create_dom_element('td', {}, v.c, row);
          cell_reference_count_1.addClass('reference_count');
          var cell_reference_count_2 = create_dom_element('td', {}, v.confirmation_c, row);
          cell_reference_count_2.addClass('reference_count');
          var cell_reference_count_3 = create_dom_element('td', {}, v.preparation_c, row);
          cell_reference_count_3.addClass('reference_count');
          break;
      }
     
      
      var cell_increment_count = create_dom_element('td',{id:'item_list_' + scope +'_'+ v.id + '_increment_button'}, v[scope + '_c'], row);
      cell_increment_count.addClass('increment');
      cell_increment_count.on('click', function() {
        item_list_increment(v.id, model, scope);
      });
      var cell_reset = create_dom_element('td',{id:'item_list_' + scope +'_' + v.id + '_reset_button'}, v.l, row);
      cell_reset.addClass('update');
    })
  } else if (type == 'static') {
    var list_container = $('#list_static_' + scope);
    list_container.html('');
    $.each(resources['notifications_' + model][scope], function(k,v) {
      var table_name = resources.tb[v.tid].n;
      var user_id = v[scope + '_uid'];
      if (user_id != null) {
        var user_name = resources.u[user_id].n;
      }
      
      var hours = v.t.substring(0,2);
      var minutes = v.t.substring(3,5);
      var seconds = v.t.substring(6,8);

      var t1 = new Date();
      t1.setHours(hours);
      t1.setMinutes(minutes);
      t1.setSeconds(seconds);

      var t2 = new Date();
      var difference = t2-t1;
      var color_intensity = Math.floor(difference/upper_delivery_time_limit * 255);
      color_intensity += 1;
      color_intensity = (color_intensity < 0) ? 255 : color_intensity;
      var color = 'rgb(' + color_intensity + ', 60, 60)';
      var waiting_time = Math.floor(difference/60000);
      var waiting_time_label = (waiting_time > 0) ? waiting_time + 'min.<br/>' : '';

      switch(scope) {
        case 'confirmation':
          var count = v.c - v.confirmation_c;
          break;
        case 'preparation':
          var count = v.confirmation_c - v.preparation_c;
          break;
        case 'delivery':
          var count = v.preparation_c - v.delivery_c;
          break;
      }
      if (count != null) {
        var label = table_name + " | " + waiting_time_label + count + ' × ' + v.l;
        var item_container = create_dom_element('div',{id:'item_list_' + scope + '_' +  v.id}, label, list_container);
        item_container.css('background-color', color);
        item_container.addClass('item_list');
      }
    })
  }
}

function item_list_confirm(id, model, scope) {
  var unconfirmed_element = $('#item_list_' + scope + '_' + id + '_unconfirmed');
  var confirmed_element = $('#item_list_' + scope + '_' + id + '_confirmed');
  var scope_count_attribute = (scope == 'preparation') ? 'preparation_c' : 'delivery_c'
  unconfirmed_element.remove();
  resources['notifications_' + model][scope][id][scope_count_attribute] = 0;
  $('#item_list_' + scope + '_' + id + '_increment_button').html(0);
  confirmed_element.show();
  $.ajax({
    method: 'post',
    data: {id:id, attribute:scope+'_count', value:0},
    url: '/items/set_attribute'
  })
}


function item_list_increment(id, model, scope) {
  var increment_button = $('#item_list_' + scope + '_' + id + '_increment_button');
  
  var scope_count_attribute = null;
  switch(scope) {
    case 'confirmation':
      var reference_count_attribute = 'c';
      var scope_count_attribute = 'confirmation_c'
      break;
    case 'preparation':
      var reference_count_attribute = 'confirmation_c';
      var scope_count_attribute = 'preparation_c'
      break;
    case 'delivery':
      var reference_count_attribute = 'preparation_c';
      var scope_count_attribute = 'delivery_c'
      break;
  }
  
  var c = resources['notifications_' + model][scope][id][scope_count_attribute];
  var r = resources['notifications_' + model][scope][id][reference_count_attribute];
  
  if ( c < r ) {
    increment_button.html(c + 1);
    resources['notifications_' + model][scope][id][scope_count_attribute] = c+1;
    increment_button.css('background-color','#3a474d');
    $.ajax({
      method: 'post',
      url: '/items/set_attribute',
      data: {id:id, attribute:scope+'_count', value:c+1},
      success: function() {
        increment_button.css('background-color','#3a4d3a');
        //increment_button.effect('highlight');
        counter_update_item_lists = 4;
        audio_enabled = false; // skip one beep
      },
      error: function() {
        increment_button.css('background-color','#74101B');
      }
    });
  }
}

function item_list_reset(id, scope) {
  var increment_button = $('#item_list_' + scope + '_' + id + '_increment_button');
  var scope_count_attribute = (scope == 'preparation') ? 'preparation_c' : 'delivery_c';
  increment_button.html(0);
  $.ajax({
    method: 'post',
    url: '/items/set_attribute',
    data: {id:id, attribute:scope+'_count', value:0},
    success: function() {
      increment_button.css('background-color','#3a4d3a');
      //increment_button.effect('highlight');
      counter_update_item_lists = 3;
    },
    error: function() {
      increment_button.css('background-color','#74101B');
    }
  })
}

function display_items_notifications() {
  $("#items_notifications_interactive").fadeIn();
  counter_update_item_lists = 1;
  audio_enabled = false; // skip one beep
}

function hide_items_notifications() {
  $("#items_notifications_interactive").fadeOut();
  counter_update_item_lists = timeout_update_item_lists;
}