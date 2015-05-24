/*
Copyright (c) 2012 Red (E) Tools Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function display_articles(cat_id) {
  $('#articles').html('');
  var article_ids = resources.c[cat_id].a;
  for (var i = 0; i < article_ids.length; i++) {
    var art_id = article_ids[i];
    var a_object = resources.a[art_id];
    var qu_ids = a_object.q;
    var abutton = create_dom_element('div',{id:"article"+art_id},a_object.n,'#articles');
    abutton.addClass('article');
    var qcontainer = $(document.createElement('div'));
    qcontainer.addClass('quantities');
    qcontainer.css('display','none');
    qcontainer.attr('id','article_' + art_id + '_quantities');
    if (qu_ids.length == 0) {
      // no submenu for quantities
      (function() { 
        var element = abutton;
        var article_id = art_id;
        abutton.on('click', function() {
          $(".optionsselect").hide();
          highlight_button(element);
          highlight_border(element);
          if (settings.workstation) {
            $('.quantities').slideUp();
          } else {
            $('.quantities').html('');
          }
          add_new_item(article_id, 'article', false);
        });
      })();
    } else {
      // render submenu for variants/quantities
      arrow = $(document.createElement('img'));
      arrow.addClass('more');
      arrow.attr('src','/assets/more.png');
      abutton.append(arrow);
      (function() {
        var article_id = art_id;
        var target = qcontainer;
        abutton.on('click', function(event) {
          $(".optionsselect").hide();
          if ($("#article_" + article_id + "_quantities").html() != "") {
            // this quantities menu is shown
            $('.quantities').html('');
          } else {
            $('.quantities').html('');
            display_quantities(article_id, target);
          }
          
        });
      })();
      qcontainer.insertAfter(abutton);
    }
  }
}
