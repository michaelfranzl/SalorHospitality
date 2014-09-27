/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function update_resources(mode) {
  //console.log('here');
  $.ajax({
    url: '/vendors/render_resources',
    dataType: 'script',
    complete: function(data,state) {
      update_resources_success(data)
    },
    timeout: 15000,
    success: function() {
      if (mode == 'documentready') {
        update_tables();
        if ( !$.isEmptyObject(resources.sn) && typeof render_season_illustration != 'undefined' ) {
          //render_season_illustration();
          create_season_objects(resources.sn);
        }
        //automatically route to views depending on uri parameters
        var uri_attrs = uri_attributes();
        if (uri_attrs.rooms == '1') {
          setTimeout(function(){
            route('rooms')
          }, 100);
        }
        if (uri_attrs.booking_id != undefined) {
          setTimeout(function(){
            route('booking', uri_attrs.booking_id);
          }, 100);
        }
        if (uri_attrs.table_id != undefined) route('table', uri_attrs.table_id);
        if (uri_attrs.report == '1') report.functions.display_popup();
        if (customer != null)
          route('table', customer); //the var customer stores the table id as set by the server. it is set in the documentready code in resources.js
      }
    }
  });
}

function update_resources_success(data) {
  emit('ajax.update_resources.success', data);
  if (user_shift_ended == true) {
    alert(i18n.your_shift_has_ended);
  }
}