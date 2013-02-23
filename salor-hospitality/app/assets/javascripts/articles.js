/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function display_articles(cat_id) {
  $('#articles').html('');
  $.each(resources.c[cat_id].a, function(art_id,art_attr) {
    a_object = this;
    var abutton = create_dom_element('div',{id:"article"+art_id},art_attr.n,'#articles');
    abutton.addClass('article');
    //abutton.html(art_attr.n);
    var qcontainer = $(document.createElement('div'));
    qcontainer.addClass('quantities');
    qcontainer.css('display','none');
    qcontainer.attr('id','article_' + art_id + '_quantities');
    (function() {
      var element = abutton;
      abutton.on('mouseup', function(){
        highlight_button(element);
      });
    })();
    //$('#articles').append(abutton);
    if (jQuery.isEmptyObject(resources.c[cat_id].a[art_id].q)) {
      (function() { 
        var element = abutton;
        var object = a_object;
        abutton.on('click', function() {
          highlight_border(element);
          if (settings.workstation) {
            $('.quantities').slideUp();
          } else {
            $('.quantities').html('');
          }
          add_new_item(object, false);
        });
      })();
    } else {
      // quantity
      arrow = $(document.createElement('img'));
      arrow.addClass('more');
      arrow.attr('src','/assets/more.png');
      abutton.append(arrow);
      (function() {
        abutton.on('click', function(event) {
          var quantities = resources.c[cat_id].a[art_id].q;
          var target = qcontainer;
          var catid = cat_id;
          display_quantities(quantities, target, catid);
        });
      })();
      qcontainer.insertAfter(abutton);
    }
  });
}
