# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

module OrdersHelper

  def compose_option_names_without_price(item)
    usage = item.usage == 1 ? "<br>#{ t 'articles.new.takeaway' }" : ''
    options = item.options.collect{ |o| "<br>#{ o.name }" }.join
    usage + options
  end

end
