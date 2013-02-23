/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function add_category_button(label,options) {
  var cat = $('<div id="'+options.id+'" class="category"></div>');
  var cat_label = '<div class="category_label"><span>'+label+'</span></div>';
  var styles = [];
  var bgcolor = "background-color: rgb(XXX);";
  var bgimage = "background-image: url('XXX');";
  cat.append(cat_label);

  for (var type in options.handlers) {
    cat.bind(type,options.handlers[type]);
  }
  for (var attr in options.attrs) {
    cat.attr(attr,options.attrs[attr]);
  }

  if (options.bgcolor) {
    styles.push(bgcolor.replace("XXX",options.bgcolor));
  }
  if (options.bgimage) {
    styles.push(bgimage.replace("XXX",options.bgimage));
  }
  cat.attr('style',styles.join(' '));
  $(options.append_to).append(cat);
}

function deselect_all_categories() {
  var container = $('#categories');
  var cats = container.children();
  for(c in cats) {
    if (cats[c].style) {
      cats[c].style.borderColor = '#555555 #222222 #222222 #555555';
    }
  }
}

function category_onmousedown(category_id, element) {
  display_articles(category_id);
  deselect_all_categories();
  highlight_border(element);
  if (settings.mobile) {
    if (settings.mobile_special) {
      y = $('#articles').position().top;
      window.scrollTo(0,y);
    } else {
      scroll_to('#articles', 7);
    }
  }
}