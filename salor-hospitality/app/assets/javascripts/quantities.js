/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function display_quantities(article_id, target) {
  if (settings.workstation) {
    target.html('');
    $('.quantities').hide();
  } else if (target.html() != '') {
    // toggle open and close submenu
    target.html('');
    return;
  }
  target.html('');
  var quantity_ids = resources.a[article_id].q;
  for (var i = 0; i < quantity_ids.length; i++) {
    var q_id = quantity_ids[i];
    var q_object = resources.q[q_id];
    var qbutton = $(document.createElement('div'));
    qbutton.addClass('quantity');
    qbutton.html(q_object.pre + " " + q_object.post);
    (function() {
      var element = qbutton;
      var quantity_id = q_id;
      qbutton.on('click', function(event) {
        $(".optionsselect").hide();
        add_new_item(quantity_id, 'quantity', false);
        highlight_button(element);
        highlight_border(element);
      });
    })();
    target.append(qbutton);
  }
  if (settings.workstation) {
    target.slideDown();
  } else {
    target.show();
  }
}