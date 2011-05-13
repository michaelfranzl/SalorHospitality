var enable_articles_search = false;

$('#drop_remove').droppable({
  hoverClass: 'hover',
  drop: function(event,ui){
    ui.draggable.remove();
    $.ajax({
      type: 'POST',
      url: 'articles/change_scope',
      data: 'scope=remove&id=' + ui.draggable.attr('id')
    });
  }
});

  //new Form.Element.Observer('article_name', 2, function(element, value) {new Ajax.Updater('search_results', '/articles/find', {asynchronous:true, evalScripts:true, onLoaded:function(request){document.getElementById('search_spinner_').style.display='none'}, onLoading:function(request){document.getElementById('search_spinner_').style.display='inline'}, parameters:'articles_search_text=' + escape(value)})})

window.setInterval(
  function() {
    if (enable_articles_search == true) {
      enable_articles_search = false;
      $.ajax({
        type: 'POST',
        url: 'articles/find',
        data: 'articles_search_text=' + $('#article_name').val()
      });
    }
  }
, 1000);
