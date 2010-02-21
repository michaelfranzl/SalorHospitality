module OrdersHelper



  def generate_js_variables(categories)
    articleslist =
    "var articleslist = new Array();" +
    categories.collect{ |cat|
      "\narticleslist[#{ cat.id }] = \"" +
      cat.articles_in_menucard.collect{ |art| "<div class='article' onclick='display_quantities(#{ art.id })'>#{ art.name }</div>" }.to_s +
      '";'
    }.to_s

    quantitylist =
    "\n\nvar quantitylist = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        "\nquantitylist[#{ art.id }] = \"" +
        art.quantities.collect{ |qu| "<div class='quantity' onclick='add_new_item(#{ qu.id })'>#{ qu.name }</div>" }.to_s +
        '";'
      }.to_s
    }.to_s

    itemdetails =
    "\n\nvar itemdetails = new Array();" +
    categories.collect{ |cat|
      cat.articles_in_menucard.collect{ |art|
        art.quantities.collect{ |qu|
          "\nitemdetails[#{ qu.id }] = new Array( '#{ qu.article.id }', '#{ qu.article.name }', '#{ qu.name }', '#{ qu.article.price }', '#{ qu.article.description }', '#{ compose_item_label(qu) }');"
        }.to_s
      }.to_s
    }.to_s
    

    @designator = 'DESIGNATOR'
    @sort = 'SORT'
    @articleid = 'ARTICLEID'
    @quantityid = 'QUANTITYID'
    @label = 'LABEL'
    new_item_html = render 'items/item', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator }
    new_item_html_var = "\n\nvar new_item_html = \"#{ escape_javascript new_item_html }\""

    return articleslist + quantitylist + itemdetails + new_item_html_var
  end



  def generate_js_functions
    display_articles   = "function display_articles(cat_id)   { document.getElementById('articles').innerHTML   = articleslist[cat_id]; document.getElementById('quantities').innerHTML  = '&nbsp;';}\n"
    display_quantities = "function display_quantities(art_id) { document.getElementById('quantities').innerHTML = quantitylist[art_id]; }\n"
    add_new_item = "function add_new_item(qu_id) {
                      var timestamp = new Date().getTime();
                      new_item_html_modified = new_item_html.replace(/DESIGNATOR/g, 'new_' + timestamp.toString().substr(-9,9));
                      new_item_html_modified = new_item_html_modified.replace(/SORT/g, timestamp.toString().substr(-9,9));
                      new_item_html_modified = new_item_html_modified.replace(/LABEL/g,  itemdetails[qu_id][5] );
                      new_item_html_modified = new_item_html_modified.replace(/ARTICLEID/g, itemdetails[qu_id][0] );
                      new_item_html_modified = new_item_html_modified.replace(/QUANTITYID/g, qu_id );
                      $('items').insert({ bottom: new_item_html_modified });
                    }"
    return display_articles + display_quantities + add_new_item
  end

  def compose_item_label(qu)
    label = "#{ qu.article.name } | #{ qu.name }"
    label += '<br>' + '| ' + qu.article.description if !qu.article.description.empty?
    return label
  end

end
