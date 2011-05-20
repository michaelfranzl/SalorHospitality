var enable_articles_search = false;

$('#drop_remove').droppable({
  hoverClass: 'hover',
  drop: function(event,ui){
    ui.draggable.remove();
    $.ajax({
      type: 'POST',
      url: '/articles/change_scope',
      data: 'scope=remove&id=' + ui.draggable.attr('id')
    });
  }
});

window.setInterval(
  function() {
    if (enable_articles_search == true) {
      enable_articles_search = false;
      $.ajax({
        type: 'POST',
        url: '/articles/find',
        data: 'articles_search_text=' + $('#article_name').val()
      });
    }
  }
, 2000);

$('#article_name').keyboard( {openOn: '' } );
$('#article_name_display_keyboard').click(function(){
  $('#article_name').getkeyboard().reveal();
});
