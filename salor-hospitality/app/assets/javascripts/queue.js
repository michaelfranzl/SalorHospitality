function send_queue_after_server_online(object_id, callback) {
  $('#order_info').html(i18n.connecting);
  $('#order_info_bottom').html(i18n.connecting);
  send_queue_attempts++;
  get_table_show_retry = false;
  $.ajax({
    type: 'GET',
    url: '/vendors/online_status',
    timeout: 10000,
    cache: false,
    complete: function(data,status) {
      if (status == 'timeout') {
        if (send_queue_attempts < 10) {
          $('#order_info').html(i18n.attempt + ' ' + send_queue_attempts);
          $('#order_info_bottom').html(i18n.attempt + ' ' + send_queue_attempts);
          setTimeout(function() {
            send_queue_after_server_online(object_id, callback);
          }, 1000);
        } else {
          $('#order_info').html(i18n.no_connection_giving_up);
          $('#order_info_bottom').html(i18n.no_connection_giving_up);
          unloadify_order_buttons();
          send_queue_attempts = 1;
          copy_json_from_submit_queue(object_id);
        }
      } else if (status == 'success') {
        $('#order_info').html(i18n.sending);
        $('#order_info_bottom').html(i18n.sending);
        send_queue(object_id, callback)
      } else if (status == 'error') {
        if (send_queue_attempts < 10) {
          $('#order_info').html(i18n.attempt + ' ' + send_queue_attempts);
          $('#order_info_bottom').html(i18n.attempt + ' ' + send_queue_attempts);
          setTimeout(function() {
            send_queue_after_server_online(object_id, callback);
          }, 1000);
        } else {
          $('#order_info').html(i18n.no_connection_giving_up);
          $('#order_info_bottom').html(i18n.no_connection_giving_up);
          unloadify_order_buttons();
          send_queue_attempts = 1;
          copy_json_from_submit_queue(object_id);
        }
      } else if (status == 'parsererror') {
      } else {
      }
    }
  });
}

var send_queue_timestamps = [];

function send_queue(object_id, callback) {
  var no_cache_timestamp = new Date().getTime();
  
  // in rare cases, due to iPod quirks (e.g. when it is switched off during a running ajax request), send_queue can be called twice for the same object_id. Check if that has happened, and if yes, warn the user.
  var sent_at = submit_json_queue[object_id].sent_at;
  var idx = send_queue_timestamps.indexOf(sent_at);

  if ( idx != -1 ) {
    unloadify_order_buttons();
    alert(i18n.double_submission_warning);
    send_email('Double submission warning', 'User has been informed');
    $('#order_info').html('');
    $('#order_info_bottom').html('');
    copy_json_from_submit_queue(object_id);
    // clearing sent_at from send_queue_timestamps
    var idx = send_queue_timestamps.indexOf(sent_at);
    send_queue_timestamps.splice(idx, 1);
    return;
  }
  
  send_queue_timestamps.push(sent_at);
  
  $.ajax({
    type: 'POST',
    url: '/route?send_queue_timestamp=' + no_cache_timestamp,
    data: submit_json_queue[object_id],
    timeout: 60000,
    complete: function(data,status) {
      unloadify_order_buttons();
      
      if (status == 'timeout') {
        send_email('send_queue: timeout', 'submit_json_queue[' + object_id + '] = ' + JSON.stringify(submit_json_queue[object_id]));
        $('#order_info').html(i18n.check_order_on_workstation);
        $('#order_info_bottom').html(i18n.check_order_on_workstation);
        alert(i18n.server_not_responded);
        //copy_json_from_submit_queue(object_id);
        //send_queue_attempts = 0;
        clear_queue(object_id);
        update_tables();
        callback();
        
      } else if (status == 'success') {
        if (submit_json_queue[object_id]) {
          // everything went okay
          // clearing timestamp from send_queue_timestamps
          var idx = send_queue_timestamps.indexOf(sent_at);
          send_queue_timestamps.splice(idx, 1);

        } else {
          alert('Error 100');
          send_email('send_queue: success, but submit_json_queue empty for object_id ' + object_id, 'This should not have happened, since send_queue should only be cleared now. User has been informed about Error 100');
        }
        clear_queue(object_id);
        update_tables();
        callback();
        
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            // this should never happen because send_queue() is only called after the server is online and a successful request is made by send_queue_after_server_online().
            // However, it can happen due to an iPod quirk: When a battery powered iPod is switched off immediately after submitting an order and the server doesn't respond within 15 seconds. In this case the iPod's firmware just re-sends the unmodified Ajax call when it is turned on again. This is bad however, since the server could have processed the items correctly and the second submission would double all items in the order. Luckily however, the iPods WiFi comes online only about 2 seconds after it was turned on again, which is too late for the second Ajax call to succeed. Therefore, the second Ajax call always fails, which puts it into the current state.
            alert('Lost connection during sending. Please check correct submission of order manually.');
            send_email('send_queue: No connection error for object_id ' + object_id, '');
            $('#order_info').html('Lost connection during sending');
            $('#order_info_bottom').html('Lost connection during sending');
            copy_json_from_submit_queue(object_id);
            send_queue_attempts = 0;
            break;
          case 4:
            send_email('send_queue: Server Error for object_id ' + object_id, '');
            $('#order_info').html('Server error');
            $('#order_info_bottom').html('Server error');
            alert(i18n.server_error);
            copy_json_from_submit_queue(object_id);
            send_queue_attempts = 0;
            break;
          default:
            $('#order_info').html('unknown ajax "readyState"');
            $('#order_info_bottom').html('unknown ajax "readyState"');
            alert('send_queue: unknown readyState for status complete.');
            send_email('send_queue: unknown readyState for status complete.', data.readyState);
        }
        
      } else if (status == 'parsererror') {
        send_email('send_queue: parsererror');
        alert(i18n.server_error);
        clear_queue(object_id); // server has processed correctly but only returned malformed JSON, so we can clear the queue.
        
      } else {
        alert('send_queue: unknown ajax complete status');
        send_email('send_queue: unknown ajax complete status', '');
      }
      
      audio_enabled = false; // skip one beep
      counter_update_item_lists = 2;
    }
  });
}

function clear_queue(i) {
  delete submit_json_queue[i];
  delete items_json_queue[i];
  $('#queue_'+i).remove();
}

/*
function display_queue() {
  $('#queue').html('');
  jQuery.each(submit_json_queue, function(k,v) {
    var link = $(document.createElement('a'));
    link.attr('id','queue_'+k);
    var div = $(document.createElement('div'));
    div.html('Re-send ' + k);
    (function(){
      var id = k;
      link.on('click', function() {
        send_queue(id);
      })
    })();
    link.append(div);
    $('#queue').append(link);
  });
}
*/