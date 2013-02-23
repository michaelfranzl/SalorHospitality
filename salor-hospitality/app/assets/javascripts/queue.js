function send_queue_after_server_online(object_id, callback) {
  $('#order_info').html('Verbinde... ');
  $('#order_info_bottom').html('Verbinde... ');
  send_queue_attempts++;
  get_table_show_retry = false;
  $.ajax({
    url: '/vendors/online_status',
    timeout: 10000,
    complete: function(data,status) {
      if (status == 'timeout') {
        if (send_queue_attempts < 10) {
          $('#order_info').html(send_queue_attempts + '. Versuch...');
          $('#order_info_bottom').html(send_queue_attempts + '. Versuch...');
          setTimeout(function() {
            send_queue_after_server_online(object_id, callback);
          }, 1000);
        } else {
          $('#order_info').html('Keine Verbindung. Gebe auf.');
          $('#order_info_bottom').html('Keine Verbindung. Gebe auf.');
          unloadify_order_buttons();
          send_queue_attempts = 1;
          copy_json_from_submit_queue(object_id);
        }
      } else if (status == 'success') {
        $('#order_info').html('Sende ...');
        $('#order_info_bottom').html('Sende ...');
        send_queue(object_id, callback)
      } else if (status == 'error') {
        if (send_queue_attempts < 10) {
          $('#order_info').html(send_queue_attempts + '. Versuch...');
          $('#order_info_bottom').html(send_queue_attempts + '. Versuch...');
          setTimeout(function() {
            send_queue_after_server_online(object_id, callback);
          }, 1000);
        } else {
          $('#order_info').html('Keine Verbindung. Gebe auf.');
          $('#order_info_bottom').html('Keine Verbindung. Gebe auf.');
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

function send_queue(object_id, callback) {
  $.ajax({
    type: 'post',
    url: '/route',
    data: submit_json_queue[object_id],
    timeout: 30000,
    complete: function(data,status) {
      unloadify_order_buttons();
      if (status == 'timeout') {
        send_email('send_queue: timeout', 'submit_json_queue[' + object_id + '] = ' + JSON.stringify(submit_json_queue[object_id]));
        $('#order_info').html('Bestellung auf Basisstation überprüfen');
        $('#order_info_bottom').html('Bestellung auf Basisstation überprüfen');
        alert("Keine Antwort vom Server. Bitte Ausdruck der Bestellung manuell überprüfen, danach nochmal absenden oder abbrechen.");
        //clear_queue(object_id); // in most cases, server has processed the request successfully, so we are clearing the queue here.
        //update_tables();
        
        copy_json_from_submit_queue(object_id);
        send_queue_attempts = 0;
        
      } else if (status == 'success') {
        if (submit_json_queue[object_id]) {
          table_id = submit_json_queue[object_id].model.table_id;
          if (offline_tables.hasOwnProperty(table_id)) {
            delete offline_tables[table_id];
            $('#table' + table_id).css('border', '1px solid gray');
          }
        } else {
          send_email('send_queue: success, but submit_json_queue empty for object_id ' + object_id, 'User has re-entered the same table before Ajax submit_queue response from the server was received. Not critical.');
        }
        clear_queue(object_id);
        update_tables();
        callback();
        
      } else if (status == 'error') {
        switch(data.readyState) {
          case 0:
            // iPod specific: This happens when a battery powered iPod is switched off immediately after taking an order and the server doesn't respond within 15 seconds after turning off due to high load. In this case the iPod's firmware just re-sends the unmodified the Ajax call when it is turned on again. This is bad however, since the server could have processed the items correctly and the second submission would double all items in the order. Luckily however, the iPods WiFi comes online only about 2 seconds after it was turned on again, which is too late for the second Ajax call to succeed. Therefore, the second Ajax call always fails, which puts it into the current state.
            send_email('send_queue: No connection error for object_id ' + object_id, '');
            copy_json_from_submit_queue(object_id);
            send_queue_attempts = 0;
            break;
          case 4:
            send_email('send_queue: Server Error for object_id ' + object_id, '');
            var table_id = submit_json_queue[object_id].model.table_id;
            $('#table' + table_id).css('border', '3px solid white');
            offline_tables[table_id] = true;
            alert("Oops! Bei der Verarbeitung der Bestellung ist ein interner Serverfehler aufgetreten. Bitte Bestellung manuell überprüfen.");
//             copy_json_from_submit_queue(object_id);
//             send_queue_attempts = 0;
            break;
          default:
            send_email('send_queue: unknown ajax "readyState" for status "complete".', '');
        }
        
      } else if (status == 'parsererror') {
        send_email('send_queue: parsererror');
        alert("Oops! Der Server hat die Bestellung erfolgreich verarbeitet, aber mit einem falsch formatierten Code geantwortet.");
        clear_queue(object_id); // server has processed correctly but only returned malformed JSON, so we can clear the queue.
        
      } else {
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