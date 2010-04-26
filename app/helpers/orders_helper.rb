module OrdersHelper

  def compose_item_label(input)
    if input.class == Quantity
      label = "#{ input.article.name }<br><small>#{ input.price } EUR, #{ input.name }</small>"
    else
      label = "#{ input.name }<br><small>#{ input.price } EUR</small>"
    end
    return label
  end

  def switch_item_js_code
    %{
      function mark_item(list_id, order_id, item_id) {
        if ( $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value == 1 ) {
          list_id.style.backgroundColor = 'white';
          $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value = 0;
        } else {
          list_id.style.backgroundColor = '#CCC';
          $('order_items_attributes_'+order_id+'_'+item_id+'_partial_order').value = 1;
        }
     }
   }
  end


  def download_invoice_js
    "Event.observe(window, 'load',
      function() {
        location.href='#{order_path(@order)}.bon';
      }
    );"
  end

  def generate_js_variables(categories)
    @designator = 'DESIGNATOR'
    @sort = 'SORT'
    @articleid = 'ARTICLEID'
    @quantityid = 'QUANTITYID'
    @price = 'PRICE'
    @label = 'LABEL'
    @count = 1

    new_item_html = render 'items/item', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :price => @price }
    new_item_html_var = "\n\nvar new_item_html = \"#{ escape_javascript new_item_html }\""

    return  new_item_html_var
  end



  def generate_js_functions

    flash_button = 'function highlight_button(element) {
                      element.style.borderColor = "white";
                   }
                   function restore_button(element) {
                      element.style.borderColor = "#555555 #222222 #222222 #555555";
                   }
                   function deselect_all_categories() {
                     var container = document.getElementById("categories");
                     var cats = container.children;
                     for(c in cats) {
                       cats[c].style.borderColor = "#555555 #222222 #222222 #555555";
                     }
                   }
                   function deselect_all_articles() {
                     var container = document.getElementById("articlestable");
                     var arts = container.rows;
                     for(count in arts) {
                       arts[count].firstChild.style.borderColor = "#555555 #222222 #222222 #555555";
                     }
                   }
                   '
                   

    display_articles   = "function display_articles(cat_id) { $('articlestable').innerHTML = articleslist[cat_id]; $('quantitiestable').innerHTML = '&nbsp;'; }\n"

    display_quantities = "function display_quantities(art_id) { $('quantitiestable').innerHTML = quantitylist[art_id]; }\n"

    add_new_item_q = "function add_new_item_q(qu_id) {
                      var timestamp = new Date().getTime();
                      var sort = timestamp.toString().substr(-9,9);
                      var desig = 'new_' + sort;
                      new_item_html_modified = new_item_html.replace(/DESIGNATOR/g, desig);
                      new_item_html_modified = new_item_html_modified.replace(/SORT/g, sort );
                      new_item_html_modified = new_item_html_modified.replace(/LABEL/g,  itemdetails_q[qu_id][5] );
                      new_item_html_modified = new_item_html_modified.replace(/PRICE/g,  itemdetails_q[qu_id][3] );
                      new_item_html_modified = new_item_html_modified.replace(/ARTICLEID/g, itemdetails_q[qu_id][0] );
                      new_item_html_modified = new_item_html_modified.replace(/QUANTITYID/g, qu_id );
                      $('itemstable').insert({ top: new_item_html_modified });
                      var sum = parseFloat($('order_sum').value.replace(',', '.')) + itemdetails_q[qu_id][3];
                      $('order_sum').value = sum.toFixed(2).replace('.', ',');
                    }"
    add_new_item_a = "function add_new_item_a(art_id) {
                      var timestamp = new Date().getTime();
                      var sort = timestamp.toString().substr(-9,9);
                      var desig = 'new_' + sort;
                      new_item_html_modified = new_item_html.replace(/DESIGNATOR/g, desig);
                      new_item_html_modified = new_item_html_modified.replace(/SORT/g, sort);
                      new_item_html_modified = new_item_html_modified.replace(/LABEL/g,  itemdetails_a[art_id][5] );
                      new_item_html_modified = new_item_html_modified.replace(/PRICE/g,  itemdetails_a[art_id][3] );
                      new_item_html_modified = new_item_html_modified.replace(/ARTICLEID/g, itemdetails_a[art_id][0] );
                      new_item_html_modified = new_item_html_modified.replace(/QUANTITYID/g, '' );
                      document.getElementById('quantitiestable').innerHTML = '&nbsp;';
                      $('itemstable').insert({ top: new_item_html_modified });
                      var sum = parseFloat($('order_sum').value.replace(',', '.')) + itemdetails_a[art_id][3];
                      $('order_sum').value = sum.toFixed(2).replace('.', ',');
                    }"
                    
    increment_item_func = "function increment_item(desig) {
                             $('count_' + desig).innerHTML = $('order_items_attributes_' + desig + '_count').value++ + 1;
                             var sum = parseFloat($('order_sum').value.replace(',', '.')) + parseFloat($(desig + '_price').value);
                             $('order_sum').value = sum.toFixed(2).replace('.', ',');
                           }"
                           
    decrement_item_func = "function decrement_item(desig) {
                             var i;
                             i = parseInt($('order_items_attributes_' + desig + '_count').value);
                             if (i < 2) {
                               Effect.DropOut('item_' + desig);
                               $('order_items_attributes_' + desig + '__delete').value = 1;
                             };
                             if (i > 0) {
                               $('count_' + desig).innerHTML = $('order_items_attributes_' + desig + '_count').value-- - 1;
                               var sum = parseFloat($('order_sum').value.replace(',', '.')) - parseFloat($(desig + '_price').value);
                               $('order_sum').value = sum.toFixed(2).replace('.', ',');
                             };
                           }"
    remove_item_func = "function remove_item(desig) {
                             Effect.DropOut('item_' + desig );
                             $('order_items_attributes_' + desig + '__delete').value = 1;
                             var sum = parseFloat($('order_sum').value.replace(',', '.')) - ( parseFloat($('order_items_attributes_' + desig + '_count').value) * parseFloat($(desig + '_price').value));
                             $('order_sum').value = sum.toFixed(2).replace('.', ',');
                        }"
    
    return display_articles + display_quantities + add_new_item_q + add_new_item_a + increment_item_func + decrement_item_func + flash_button + remove_item_func
  end





end
