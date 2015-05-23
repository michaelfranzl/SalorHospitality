/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function add_option_to_item(id, d) {
  if (id == 0) {
    // special id, meaning "clear all options"
    set_json('order', d, 'i', [0]);
    set_json('order', d, 't', {});
    $('#optionsnames_' + d).html('');
  } else {
    $('#options_select_' + d).val(''); //needed for mobile phones to be able to choose the same option seveal times
    d = clone_item(d);
    var object = resources.o[id];
    var option_uid = (new Date).getTime();
    items_json[d].t[option_uid] = object;
    //var stripped_id = value.split('_')[1];
    var list = items_json[d].i;
    list.push(id);
    set_json('order', d, 'i', list);
    $('#optionsnames_' + d).append('<br>' + object.n + ' ' + number_to_currency(object.p));
  }
  calculate_sum();
}

function render_options(option_ids, d) {
  //console.log('rendering options', option_ids, d);
  if (option_ids.length == 0) return;
  
  if (permissions.add_option_to_sent_item == false) {
    var clearbutton = create_dom_element('span',{},'&nbsp;✗&nbsp;','#options_div_' + d);
    clearbutton.addClass('option');
    clearbutton.on('click', function() {
      add_option_to_item(0, d);
    })
  }
  for (var i = 0; i < option_ids.length; i++) {
    //console.log(i);
    var o_id = option_ids[i];
    var object = resources.o[o_id];
    var button = $(document.createElement('span'));
    
    button.html(object.n);
    button.addClass('option');
    (function() {
      var option_id = o_id;
      button.on('click',function(){
        $(this).effect('highlight');
        add_option_to_item(option_id, d);
      });
    })();
    $('#options_div_' + d).append(button);
  }
}

function open_options_div(d) {
  if (item_changeable(d) || permissions.add_option_to_sent_item) {
    d = clone_item(d);
    $(".optionsselect").hide();
    if (settings.mobile) {
      $('#options_div_'+d).show();
    } else {
      $('#options_div_'+d).slideDown();
    }
  }
}

function close_options_div(d) {
  if (settings.mobile) {
    $('#options_div_'+d).hide();
  } else {
    $('#options_div_'+d).slideUp();
  }
}

function compose_optionnames(object){
  names = '';
  jQuery.each(object.t, function(k,v) {
    names += (v.n + ' ' + number_to_currency(v.p) + '<br />')
  });
  return names;
}

function permit_select_open(d) {
  if ( item_changeable(d) ) {
    $('#options_select_' + d).attr('disabled',false);
  } else {
    $('#options_select_' + d).attr('disabled',true);
  }
}