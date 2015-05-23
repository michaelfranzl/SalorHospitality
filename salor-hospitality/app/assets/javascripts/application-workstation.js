/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


  
var automatic_printing_interval = 60000;

$(document).ready(function() {
  
  // ":not([safari])" is desirable but not necessary selector
  $('input:checkbox:not([safari])').checkbox();
  $('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
  $('input:radio').checkbox();
  
  $('#admin_menu_hint').fadeOut(6000);
        
  if ($('#flash').children().size() > 0) {
    $('#flash').fadeIn(1000);
    setTimeout(function(){
      $('#flash').fadeOut(2000);
    }, 6000);
  }
  
  if (typeof(automatic_printing_timeout) == 'undefined') {
    automatic_printing_timeout = window.setInterval(function() {
      if ( automatic_printing == true ) {
        if ( window.location.port == '' ) {
          download_printfile(1);
        } else {
          console.log("Automatic printing not available in development mode.");
        }
      }
    }, automatic_printing_interval);
  }
  
  if ( is_fullscreen() == false ) {
    $('#exit_button').hide();
  }
  
  $('#admin').hide();

  $(function() {
    $.each($('select'), function(k,v) {
      make_select_widget($(v));
    });
  });
})

function download_printfile(path) {
  var subdomain = window.location.host.replace('.red-e.eu','');
  //url_parts = window.location.host.split('.');
  //$.each(vendor_printers, function(k,v) {
  for (var first_key in vendor_printers) { break }
  var printer = vendor_printers[first_key];
  var printer_path = printer.p;
  window.location.href = '/uploads/' + sh_debian_siteid + '/' + company_identifier + '/' + printer_path + '.bill';
}

function is_fullscreen() {
  return window.outerWidth == screen.width && window.outerHeight == screen.height;
}
