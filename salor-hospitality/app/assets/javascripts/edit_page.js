/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var enable_articles_search = false;

function set_handles() {
  $('span.handle').each(function () {
    if (!$(this).hasClass('toolbox-done')) {
      $(this).dblclick(function (event) {
      $('span.handle').each(function () {
        var id = $(this).attr('href');
        $(id).hide();
      });
      $(this).attr('old_z_index',$(this).css('z-index'));
      var id = $(this).attr('href');
      var x = parseInt($(this).position().left) - 20;
      var y = parseInt($(this).position().top) - 5;
      var cbtn = $("<span class='finish'></div>");
      cbtn.css({cursor: 'pointer', 
      position: 'relative', 
      bottom: 0, 
      right: 0});
      $(id).append(cbtn);
      cbtn.click(function () {
        $(this).parent().hide();
        $(this).remove();
      });
      $(id).show();
      $(id).css({position: 'absolute', top: y, left: x});
      $(this).css('z-index',1002);
      });
      $(this).addClass('toolbox-done')
    }
  });
}

$(function() {
  set_handles();
  
  $('#remove').droppable({
    hoverClass: 'hover',
    drop: function(event,ui){
      ui.draggable.remove();
      $.ajax({
        type: 'DELETE',
        url: '/partials/' + ui.draggable.attr('partial_id')
      });
    }
  });
  
  window.setInterval(
    function() {
      if (enable_articles_search == true) {
        enable_articles_search = false;
        $.ajax({
          type: 'POST',
          url: '/pages/find',
          data: 'search_text=' + $('#search_text').val()
        });
      }
    }
  , 2000);
  
  $('#search_text').keyboard( {openOn: '', accepted: function(){ enable_articles_search = true } } );
  $('#search_text_display_keyboard').click(function(){
    $('#search_text').val('');
    $('#search_text').getkeyboard().reveal();
  });
  
  $("#page_color").colpick();
});