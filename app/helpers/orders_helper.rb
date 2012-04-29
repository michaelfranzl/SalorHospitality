# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

module OrdersHelper

  def compose_item_label(item)
    if item.quantity
      "#{ item.quantity.prefix } #{ item.article.name } #{ item.quantity.postfix }"
    else
      item.article.name
    end
  end

  def compose_option_names(item)
    usage = item.usage == 1 ? "<br>#{ t 'articles.new.takeaway' }" : ''
    options = item.options.collect{ |o| "<br>#{ o.name } #{ number_to_currency o.price }" }.join
    usage + options
  end

  def generate_js_variables
    id = ''
    designator = 'DESIGNATOR'
    sort = 'SORT'
    articleid = 'ARTICLEID'
    quantityid = 'QUANTITYID'
    price = 'PRICE'
    label = 'LABEL'
    usage = 0
    optionslist = ''
    printed_count = 0
    optionsselect = 'OPTIONSSELECT'
    optionsnames = ''
    count = 1

    new_item_tablerow = render :partial => 'items/item_tablerow', :locals => { :item => nil, :sort => sort, :articleid => articleid, :quantityid => quantityid, :label => label, :designator => designator, :count => count, :price => price, :optionslist => optionslist, :optionsnames => optionsnames, :optionsselect => optionsselect, :comment => nil }
    new_item_tablerow_var = raw("new_item_tablerow = \"#{ escape_javascript new_item_tablerow }\";")

    new_item_inputfields = render :partial => 'items/item_inputfields', :locals => { :item => nil, :sort => sort, :articleid => articleid, :quantityid => quantityid, :label => label, :designator => designator, :count => count, :printed_count => printed_count, :price => price, :optionslist => optionslist, :optionsnames => optionsnames, :optionsselect => optionsselect, :comment => nil, :id => nil, :usage => usage }
    new_item_inputfields_var = raw("\nnew_item_inputfields = \"#{ escape_javascript new_item_inputfields }\";")

    return new_item_tablerow_var + new_item_inputfields_var
  end

end
