module OrdersHelper

  def compose_item_label(item)
    return "#{ item.quantity.prefix if item.quantity } #{ item.article.name } #{ item.quantity.postfix if item.quantity }"
  end

  def compose_option_names(item)
    item.printoptions.collect{ |o| "<br>#{ o.name } " }.join +
    item.options.collect{ |o| "<br>#{ o.name } " }.join
  end

  def compose_option_select(item)
    Option.find(:all, :conditions => { :category_id => item.category.id }).collect{ |o| "<option value=#{ o.id }>#{ o.name }</option>" }.join
  end

  def generate_js_variables
    @id = ''
    @designator = 'DESIGNATOR'
    @sort = 'SORT'
    @articleid = 'ARTICLEID'
    @quantityid = 'QUANTITYID'
    @price = 'PRICE'
    @label = 'LABEL'
    @optionslist = ''
    @printoptionslist = ''
    @printed_count = 0
    @optionsselect = 'OPTIONSSELECT'
    @optionsnames = ''
    @count = 1

    new_item_tablerow = render 'items/item_tablerow', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :price => @price, :optionslist => @optionslist, :optionsnames => @optionsnames, :optionsselect => @optionsselect }
    new_item_tablerow_var = raw("var new_item_tablerow = \"#{ escape_javascript new_item_tablerow }\"")

    new_item_inputfields = render 'items/item_inputfields', :locals => { :sort => @sort, :articleid => @articleid, :quantityid => @quantityid, :label => @label, :designator => @designator, :count => @count, :printed_count => @printed_count, :price => @price, :optionslist => @optionslist, :optionsnames => @optionsnames, :optionsselect => @optionsselect }
    new_item_inputfields_var = raw("\nvar new_item_inputfields = \"#{ escape_javascript new_item_inputfields }\"")

    return new_item_tablerow_var + new_item_inputfields_var
  end

end
