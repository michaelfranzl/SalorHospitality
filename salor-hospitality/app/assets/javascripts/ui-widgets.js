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

/* Adds a delete/X button to the element. Type options  are right and append. The default callback simply slides the element up.
 if you want special behavior on click, you can pass a closure.*/
function deletable(elem,type,callback) {
  if (typeof type == 'function') {
    callback = type;
    type = 'right'
  }
  if (!type)
    type = 'right';
  if ($('#' + elem.attr('id') + '_delete').length == 0) {
    var del_button = create_dom_element('div',{id: elem.attr('id') + '_delete', 'class':'delete', 'target': elem.attr('id')},'',elem);
    if (!callback) {
      del_button.on('click',function () {
        $('#' + $(this).attr('target')).slideUp();
      });
    } else {
      del_button.on('click',callback);
    }
  } else {
    var del_button = $('#' + elem.attr('id') + '_delete');
  }
  var offset = elem.offset();
  if (type == 'right') {
    offset.left += elem.outerWidth() - del_button.outerWidth() - 5;
    offset.top += 5
    del_button.offset(offset);
  } else if (type == 'append') {
    elem.append(del_button);
  }
  
}

/* Adds a top button menu to the passed div. offset_padding will be added to the offset before it is used.*/
function add_button_menu(elem,offset_padding) {
  if (!offset_padding) {
    offset_padding = {top: 0, left: 0};
  }
  var menu_id = elem.attr('id') + '_button_menu';
  if ($('#' + menu_id).length == 0) {
    var menu = create_dom_element('div',{id:menu_id,target:elem.attr('id')},'',elem);
    menu.addClass('button_menu');
  } else {
    var menu = $('#' + menu_id);
  }
  var parent_zindex = elem.css('zIndex');
  var menu_width = elem.outerWidth() - (elem.outerWidth() / 4);
  var new_offset = elem.offset();
  new_offset.top -= (menu.outerHeight() - 5);
  new_offset.left += 10;
  new_offset.top += offset_padding.top;
  new_offset.left += offset_padding.left;
  menu.offset(new_offset);
  menu.css({width: menu_width});
  /* we emit the render and include the element, which will be even.packet. You will have to
   decide if it is the menu you want in your listener. probably by checking the id of even.packet.attr('id') == 'my_id'*/
  emit("button_menu.rendered", elem);
}

/* adds a button element, as created by you, to the button menu of the element. note, this function
 wants the parent div element, not the actual button menu.*/
function add_menu_button(elem,button,callback) {
  var menu = elem.find('.button_menu');
  menu.append(button);
  button.on('click',callback);
}



function make_select_widget(elem) {
  if (elem.attr("no_select_widget") == 1 || elem.attr("no_select_widget") == "1")
    return;
  elem.hide();
  elem.attr("no_select_widget", 1);
  var button = create_dom_element('span', {id:'select_widget_button_for_' + elem.attr("id")});
  button.addClass("button select-widget-button");
  button.html(elem.find("option:selected").text());
  if (button.html() == "")
    button.html("☟");
  button.insertAfter(elem);
  if (elem.children("option").length > 0) {
    button.on('click', function () {
      if ($('#select_widget_container_'+ elem.attr("id")).length > 0)
        return;
      var mdiv = create_dom_element('div', {id:'select_widget_container_'+ elem.attr("id")}, '');
      mdiv.addClass('select-widget-display');
      $.each(elem.children("option"), function (k,v) {
        var text = $(v).text();
        if (text == "")
          text = "&nbsp;";
        var o = create_dom_element('span', {value:$(v).val()}, text);
        o.addClass('button select-widget-entry');
        if (elem.val() == $(v).val()) {
          o.addClass('select-widget-entry-selected');
        }
        o.on('click', function () {
          elem.find("option:selected").removeAttr("selected");
          elem.find("option[value='" + $(this).attr("value") + "']").attr("selected","selected");
          elem.change();
          button.html(o.html());
          mdiv.remove();
        });
        mdiv.append(o);
      });
      mdiv.css({position: 'absolute'});
      $('body').append(mdiv);
      mdiv.offset({left: button.offset().left - 50, top: button.offset().top - 50});
      mdiv.show();
    });
  }
}