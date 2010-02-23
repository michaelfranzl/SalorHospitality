module OrdersHelper



  def generate_js_variables(categories)
    articleslist =
    "var articleslist = new Array();" +
    categories.collect{ |cat|
      "\narticleslist[#{ cat.id }] = \"" +
      cat.articles_in_menucard.collect{ |art|
        action = art.quantities.empty? ? "add_new_item_a(#{ art.id })" : "display_quantities(#{ art.id })"
        "<div class='article' onclick='#{ action }'>#{ art.name }</div>"
      }.to_s + '";'
    }.to_s

    quantitylist =
    "\n\nvar quantitylist = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        next if art.quantities.empty?
        "\nquantitylist[#{ art.id }] = \"" +
        art.quantities.collect{ |qu|
          "<div class='quantity' onclick='add_new_item_q(#{ qu.id })'>#{ qu.name }</div>"
        }.to_s + '";'
      }.to_s
    }.to_s

    itemdetails_q =
    "\n\nvar itemdetails_q = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        art.quantities.collect{ |qu|
          "\nitemdetails_q[#{ qu.id }] = new Array( '#{ qu.article.id }', '#{ qu.article.name }', '#{ qu.name }', '#{ qu.article.price }', '#{ qu.article.description }', '#{ compose_item_label(qu) }');"
        }.to_s
      }.to_s
    }.to_s
    

    itemdetails_a =
    "\n\nvar itemdetails_a = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        "\nitemdetails_a[#{ art.id }] = new Array( '#{ art.id }', '#{ art.name }', '#{ art.name }', '#{ art.price }', '#{ art.description }', '#{ compose_item_label(art) }');"
      }.to_s
    }.to_s


    @designator = 'DESIGNATOR'
    @sort = 'SORT'
    @articleid = 'ARTICLEID'
    @quantityid = 'QUANTITYID'
    @label = 'LABEL'
    new_item_html = render 'items/item', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator }
    new_item_html_var = "\n\nvar new_item_html = \"#{ escape_javascript new_item_html }\""

    return articleslist + quantitylist + itemdetails_a + itemdetails_q + new_item_html_var
  end



  def generate_js_functions
    display_articles   = "function display_articles(cat_id)   { document.getElementById('articles').innerHTML   = articleslist[cat_id]; document.getElementById('quantities').innerHTML  = '&nbsp;';}\n"
    display_quantities = "function display_quantities(art_id) { document.getElementById('quantities').innerHTML = quantitylist[art_id]; }\n"
    add_new_item_q = "function add_new_item_q(qu_id) {
                      var timestamp = new Date().getTime();
                      new_item_html_modified = new_item_html.replace(/DESIGNATOR/g, 'new_' + timestamp.toString().substr(-9,9));
                      new_item_html_modified = new_item_html_modified.replace(/SORT/g, timestamp.toString().substr(-9,9));
                      new_item_html_modified = new_item_html_modified.replace(/LABEL/g,  itemdetails_q[qu_id][5] );
                      new_item_html_modified = new_item_html_modified.replace(/ARTICLEID/g, itemdetails_q[qu_id][0] );
                      new_item_html_modified = new_item_html_modified.replace(/QUANTITYID/g, qu_id );
                      $('items').insert({ bottom: new_item_html_modified });
                    }"
    add_new_item_a = "function add_new_item_a(art_id) {
                      var timestamp = new Date().getTime();
                      timestamp = 'new_' + timestamp.toString().substr(-9,9);
                      new_item_html_modified = new_item_html.replace(/DESIGNATOR/g, timestamp);
                      new_item_html_modified = new_item_html_modified.replace(/SORT/g, timestamp.toString().substr(-9,9));
                      new_item_html_modified = new_item_html_modified.replace(/LABEL/g,  itemdetails_a[art_id][5] );
                      new_item_html_modified = new_item_html_modified.replace(/ARTICLEID/g, itemdetails_a[art_id][0] );
                      new_item_html_modified = new_item_html_modified.replace(/QUANTITYID/g, '' );
                      document.getElementById('quantities').innerHTML = '&nbsp;';
                      $('items').insert({ bottom: new_item_html_modified });
                    }"
    return display_articles + display_quantities + add_new_item_q + add_new_item_a
  end

  def compose_item_label(input)
    if input.class == Quantity
      label = "#{ input.article.name } | #{ input.name }"
      label += '<br>' + '| ' + input.article.description if !input.article.description.empty?
    else
      label = "#{ input.name }"
    end
    return label
  end

end
