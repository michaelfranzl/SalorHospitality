/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

$(document).ready(function() {
  // ":not([safari])" is desirable but not necessary selector
  $('input:checkbox:not([safari])').checkbox();
  $('input[safari]:checkbox').checkbox({cls:'jquery-safari-checkbox'});
  $('input:radio').checkbox();
  
  if ($('#flash').children().size() > 0) {
    $('#flash').fadeIn(1000);
    setTimeout(function(){ $('#flash').fadeOut(1000); }, 5000);
  }
  
  if (typeof(automatic_printing_timeout) == 'undefined') {
    automatic_printing_timeout = window.setInterval(function() {
      if ( automatic_printing == true ) {
        download_printfile(1);
      }
    }, 15000);
  }
  
  $('#admin').hover(function(){
    $('#admin').stop(true,true);
    $('#admin').animate({height:154});
  },
  function(){
    $('#admin').stop(true,true);
    $('#admin').animate({height:109});
  })
})

function download_printfile(path) {
  url_parts = window.location.host.split('.');
  //$.each(vendor_printers, function(k,v) {
  window.location.href = '/uploads/' + url_parts[0] + '/' + path + '.salor';
}
