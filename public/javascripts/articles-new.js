var enable_articles_search = false;

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

$('#article_description').keyboard( {openOn: '' } );
$('#article_description_display_keyboard').click(function(){
  $('#article_description').getkeyboard().reveal();
});

$('#article_price').keyboard( {openOn: '' } );
$('#article_price_display_keyboard').click(function(){
  $('#article_price').getkeyboard().reveal();
});

$('#add_quantity').click(function(){
  var new_quantity_id = new Date().getTime();
  var quantity_template =  quantity_fields;
  $('#quantities_new').append(quantity_template.replace(/\d/g, 'new_' + new_quantity_id));
  $('#article_quantities_attributes_new_' + new_quantity_id + '_prefix').keyboard( {openOn: '' } );
  $('#article_quantities_attributes_new_' + new_quantity_id + '_prefix_display_keyboard').click(function(){
    $('#article_quantities_attributes_new_' + new_quantity_id + '_prefix').getkeyboard().reveal();
  });
});
