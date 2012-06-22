/*
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
*/

var tableupdates = -1;
var automatic_printing = false;
var debugmessages = [];
var _CTRL_DOWN = false;
var _key_codes = {tab: 9,shift: 16, ctrl: 17, alt: 18, f2: 113};
var _keys_down = {tab: false,shift: false, ctrl: false, alt: false, f2: false};
$(function(){
  jQuery.ajaxSetup({
      'beforeSend': function(xhr) {
          //xhr.setRequestHeader("Accept", "text/javascript");
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }
  })

  if (typeof(automatic_printing_timeout) == 'undefined') {
    automatic_printing_timeout = window.setInterval(function() {
      if ( automatic_printing == true ) { window.location.href = '/items.bill'; }
    }, 10000);
  }
  $(window).keydown(function(e){
    for (var key in _key_codes) {
      if (e.keyCode == _key_codes[key]) {
        _keys_down[key] = true;
      }
    }
  });
  $(window).keyup(function(e){
    for (var key in _key_codes) {
      if (e.keyCode == _key_codes[key]) {
        _keys_down[key] = false;
      }
    }
  });
})
/*
 *  Allows us to latch onto events in the UI for adding menu items, i.e. in this case, customers, but later more.
 */
function emit(msg,packet) {
  $('body').triggerHandler({type: msg, packet:packet});
}

function connect(unique_name,msg,fun) {
  var pcd = _get('plugin_callbacks_done');
  if (!pcd)
    pcd = [];
  if (pcd.indexOf(unique_name) == -1) {
    $('body').on(msg,fun);
    pcd.push(unique_name);
  }
  _set('plugin_callbacks_done',pcd)
}
function _get(name,context) {
  if (context) {
    // if you pass in a 3rd argument, which should be an html element, then that is set as teh context.
    // this ensures garbage collection of the values when that element is removed.
    return $.data(context[0],name);
  } else {
    return $.data(document.body,name);
  }
}
function _set(name,value,context) {
  if (context) {
    // if you pass in a 3rd argument, which should be an html element, then that is set as teh context.
    // this ensures garbage collection of the values when that element is removed.
    return $.data(context[0],name,value);
  } else {
    return $.data(document.body,name,value);
  } 
}
function scroll_to(element, speed) {
  target_y = $(window).scrollTop();
  current_y = $(element).offset().top;
  if (settings.workstation) {
    do_scroll((current_y - target_y)*1.05, speed);
  } else {
    window.scrollTo(0, current_y);
  }
}

function scroll_for(distance, speed) {
  do_scroll(distance, speed);
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

function do_scroll(diff, speed) {
  window.scrollBy(0,diff/speed);
  newdiff = (speed-1)*diff/speed;
  scrollAnimation = setTimeout(function(){ do_scroll(newdiff, speed) }, 20);
  if(Math.abs(diff) < 5) { clearTimeout(scrollAnimation); }
}

function debug(message) {
  if ( debugmessages.length > 7 ) { debugmessages.shift(); }
  debugmessages.push(message);
  $('#messages').html(debugmessages.join('<br />'));
}


function toggle_all_option_checkboxes(source) {
  if ($(source).attr('checked') == 'checked') {
    $('input.category_checkbox:checkbox').attr('checked',true);
  } else {
    $('input.category_checkbox:checkbox').attr('checked',false);
  }
}

function date_as_ymd(date) {
  return date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate();
}
function get_date(str) {
  return new Date(Date.parse(str));
}
/*
  _fetch is a quick way to fetch a result from the server.
 */
function _fetch(url,callback) {
  $.ajax({
    url: url,
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
    console.log(jqXHR,status,err.get_message());
  };
  var user_options = {};
  var url;
  for (var i = 0; i < arguments.length; i++) {
    switch(typeof arguments[i]) {
      case 'object':
        if (!payload) {
          payload = {currentview: 'push', model: {}}
          $.each(arguments[i], function (key,value) {
            console.log(key,value);
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
    type: 'post', 
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
function create_dom_element (tag,attrs,content,append_to) {
  element = $(document.createElement(tag));
  $.each(attrs, function (k,v) {
    element.attr(k, v);
  });
  element.html(content);
  if (append_to != '')
    $(append_to).append(element);
  return element;
}
/*
  Call this function on an input that you want to have auto complete functionality.
  requires a jquery element, a dictionary (array, or object, or hash mapping)
  options, which is an object where the only required key is the field if you use an object, or hash mapping, then a callback,
  which is what function to run when someone clicks a search result.
  
  On an input try:
  
  auto_completable($('#my_input'),['abc yay','123 ghey'],{},function (result) {
      alert('You chose ' + result);
  });
  in the callback, $(this) == $('#my_input')
 */
function auto_completable(element,dictionary,options,callback) {
  var key = 'auto_completable.' + element.attr('id');
  element.attr('auto_completable_key',key);
  _set(key + ".dictionary",dictionary,element); // i.e. we set the context of the variable to the element so that it will be gc'ed
  _set(key + ".options", options,element);
  _set(key + ".callback", callback,element);
  element.on('keyup',function () {
    var val = $(this).val();
    var key = $(this).attr('auto_completable_key');
    var results = [];
    if (val.length > 2) {
      var options = _get(key + '.options',$(this));
      var dictionary = _get(key + ".dictionary",$(this));
      if (options.map) { 
        // We are using a hash map, where terms are organized by first letter, then first two letters
        var c = val.substr(0,1).toLowerCase();
        var c2 = val.substr(0,2).toLowerCase();
        // i.e. if the search term is doe, the check to see if dictionary['d'] is set
        if (dictionary[c]) {
          // i.e. if the search term is doe, the check to see if dictionary['do'] is set
          if (dictionary[c][c2]) {
            // i.e. we consider dictionary['do'] to be an array of objects
            for (var i in dictionary[c][c2]) {
              // we assume that you have set options { field: "name"} or some such
              if (dictionary[c][c2][i][options.field].toLowerCase().indexOf(val.toLowerCase()) != -1) {
                results.push(dictionary[c][c2][i]);
              }
            }
          }
        }
      } else { // We assume that it's just an array of possible values
        for (var i = 0; i < dictionary.length; i++) {
          if (options.field) {
            if (dictionary[i][options.field].indexOf(val.toLowerCase()) != -1) {
              results.push(dictionary[i])
            } 
          } else {
            if (dictionary[i].indexOf(val.toLowerCase()) != -1) {
              results.push(dictionary[i])
            } 
          }
        }
      }
    }
    auto_completable_show_results($(this),results);
  });
}
function auto_completable_show_results(elem,results) {
  $('#auto_completable').remove();
  if (results.length > 0) {
    var key = elem.attr('auto_completable_key');
    var options = _get(key + '.options',elem);
    ac = create_dom_element('div',{id: 'auto_completable'},'',$('body'));
    var offset = elem.offset();
    var css = {left: offset.left, top: offset.top + elem.outerHeight(), width: elem.outerWidth() + ($.support.boxModel ? 0 : 2)};
    ac.css(css);
    for (var i in results) {
      var result = results[i];
      var div = create_dom_element('div',{'class': 'result'},result[options.field],ac);
      // i.e. we set up the vars we will need on the callback on the element in context
      _set('auto_completable.result',result,div);
      _set('auto_completable.target',elem,div);
      div.on('click', function () {
        var target = _get('auto_completable.target',$(this));
        var result = _get('auto_completable.result',$(this));
        var key = target.attr('auto_completable_key');
        var callback = _get(key + ".callback",target);
        callback.call(target,result,$(this)); //i.e. the callback will be executed with the input as this, the result is the first argument
        // the last optional argument will be the origin of the event, i.e. the div
        $('#auto_completable').remove();
      });
    }
  }
}

function days_between_dates(from, to) {
  var days = Math.floor((Date.parse(to) - Date.parse(from)) / 86400000);
  if (days == 0)
    days = 0
  return days;
}
function _log(arg1,arg2,arg3) {
 console.log(arg1,arg2,arg3);
}