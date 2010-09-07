module OrdersHelper

  def compose_item_label(input)
    if not input.quantity.nil?
      label = "#{ input.article.name }<br><small>#{ input.real_price } EUR, #{ input.quantity.name } #{ input.comment }</small>"
    else
      label = "#{ input.article.name }<br><small>#{ input.real_price } EUR #{ input.comment }</small>"
    end
    return label
  end

  def compose_item_options(input)
    if not input.quantity.nil?
      label = "#{ input.article.name }<br><small>#{ input.real_price } EUR, #{ input.quantity.name } #{ input.comment }</small>"
    else
      label = "#{ input.article.name }<br><small>#{ input.real_price } EUR #{ input.comment }</small>"
    end
    return label
  end

  def generate_js_variables
    @designator = 'DESIGNATOR'
    @sort = 'SORT'
    @articleid = 'ARTICLEID'
    @quantityid = 'QUANTITYID'
    @price = 'PRICE'
    @label = 'LABEL'
    @options = 'OPTIONS'
    @count = 1

    new_item_tablerow = render 'items/item_tablerow', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :price => @price, :options => @options }
    new_item_tablerow_var = "\n\nvar new_item_tablerow = \"#{ escape_javascript new_item_tablerow }\""

    new_item_inputfields = render 'items/item_inputfields', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :price => @price, :options => @options }
    new_item_inputfields_var = "\n\nvar new_item_inputfields = \"#{ escape_javascript new_item_inputfields }\""

    return  new_item_tablerow_var, new_item_inputfields_var
  end

end
