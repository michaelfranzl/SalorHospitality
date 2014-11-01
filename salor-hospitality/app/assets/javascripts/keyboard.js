function enable_keyboard_for_items(item_designator) {
  $('input#comment_for_item_' + item_designator).keyboard({
    openOn: '',
    visible: function(){
      $('.ui-keyboard-input').select();
    },
    accepted: function() {
      add_comment_to_item(item_designator);
    }
  });
  $('#comment_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#comment_for_item_' + item_designator).getkeyboard().reveal();
  });
  $('input#price_for_item_' + item_designator).keyboard({
    openOn: '',
    layout: 'num',
    visible: function(){
      $('.ui-keyboard-input').select();
    },
    accepted: function() {
      add_price_to_item(item_designator);
    }
  });
  $('#price_for_item_' + item_designator + '_display_keyboard').click(function(){
    $('input#price_for_item_' + item_designator).getkeyboard().reveal();
  });
}

function catch_keypress(d,type) {
  if (event.keyCode == 27) {
    // Escape
  } else if (event.keyCode == 13) {
    // Enter
    if (type == 'comment') {
      add_comment_to_item(d);
    } else if (type == 'price') {
      add_price_to_item(d);
    }
  }
}