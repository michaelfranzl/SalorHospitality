module OrdersHelper

  def compose_item_label(input)
    if input.class == Quantity
      label = "#{ input.article.name }<br><small>#{ input.price } EUR, #{ input.name }</small>"
    else
      label = "#{ input.name }<br><small>#{ input.price } EUR</small>"
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
    @count = 1

    new_item_html = render 'items/item', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :price => @price }
    new_item_html_var = "\n\nvar new_item_html = \"#{ escape_javascript new_item_html }\""

    return  new_item_html_var
  end

end
