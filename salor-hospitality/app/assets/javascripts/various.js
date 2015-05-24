/*
  _fetch is a quick way to fetch a result from the server.
 */
function _fetch(url,callback) {
  $.ajax({
    type: 'GET',
    url: url,
    cache: false,
    context: window,
    success: callback
  });
}
/*
 *  _push is a quick way to deliver an object to the server
 *  It takes a data object, a string url, and a success callback.
 *  Additionally, you can pass, after those three an error callback,
 *  and an object of options to override the options used with
 *  the ajax request.
 */
function _push(object) {
  var payload = null;
  var callback = null;
  var error_callback = function (jqXHR,status,err) {
    //console.log(jqXHR,status,err.get_message());
  };
  var user_options = {};
  var url;
  for (var i = 0; i < arguments.length; i++) {
    switch(typeof arguments[i]) {
      case 'object':
        if (!payload) {
          payload = {currentview: 'push', model: {}}
          $.each(arguments[i], function (key,value) {
            payload[key] = value;
          });
        } else {
          user_options = arguments[i];
        }
        break;
      case 'function':
        if (!callback) {
          callback = arguments[i];
        } else {
          error_callback = arguments[i];
        }
        break;
      case 'string':
        url = arguments[i];
        break;
    }
  }
  options = { 
    context: window,
    url: url, 
    type: 'POST', 
    data: payload, 
    timeout: 20000, 
    success: callback, 
    error: error_callback
  };
  if (typeof user_options == 'object') {
    $.each(user_options, function (key,value) {
      options[key] = value;
    });
  }
  $.ajax(options);
}


function order_already_finished() {
  alert(i18n.already_finished_warning);
  route("tables");
}




function uri_attributes() {
  // This function is anonymous, is executed immediately and 
  // the return value is assigned to QueryString
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
        // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
        // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
        // If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  } 
    return query_string;
};

function unlock_user_ip(user_id) {
  $.ajax({
    type: 'GET',
    url: '/users/unlock_ip',
    cache: false,
    data: {id:user_id}
  });
}

function  in_array_of_hashes(array,key,value) {
  for (var i in array) {
    if (array[i][key]) {
      try {
        if (array[i][key] == value) {
          return true;
        } else if (array[i][key].indexOf(value) != -1){
          return true;
        }
      } catch (e) {
        return false;
      }
    }
  }
  return false;
}

function logout(msg) {
  msg = typeof msg !== 'undefined' ? msg : {};
  var error = typeof msg.error !== 'undefined' ? msg.error : '';
  var notice = typeof msg.notice !== 'undefined' ? msg.notice : '';
  var type = typeof msg.type !== 'undefined' ? msg.type : '';
  $('#logout_error').val(error);
  $('#logout_notice').val(notice);
  $('#logoutform').submit();
}

function generate_password(length) {
  var charset = "abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  var pw = "";
  for (var i = 0, n = charset.length; i < length; ++i) {
    pw += charset.charAt(Math.floor(Math.random() * n));
  }
  return pw;
}