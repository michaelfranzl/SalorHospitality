# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module OrdersHelper

  def compose_item_label(item)
    if item.quantity
      "#{ item.quantity.prefix } #{ item.article.name } #{ item.quantity.postfix }"
    else
      item.article.name
    end
  end

  def compose_option_names(item)
    item.all_options.collect{ |o| "<br>#{ o.name } #{ number_to_currency o.price }" }.join
  end

  def generate_js_variables
    id = ''
    designator = 'DESIGNATOR'
    sort = 'SORT'
    articleid = 'ARTICLEID'
    quantityid = 'QUANTITYID'
    price = 'PRICE'
    label = 'LABEL'
    optionslist = ''
    printoptionslist = ''
    printed_count = 0
    optionsselect = 'OPTIONSSELECT'
    optionsnames = ''
    count = 1

    new_item_tablerow = render :partial => 'items/item_tablerow', :locals => { :item => nil, :sort => sort, :articleid => articleid, :quantityid => quantityid, :label => label, :designator => designator, :count => count, :price => price, :optionslist => optionslist, :optionsnames => optionsnames, :optionsselect => optionsselect, :comment => nil }
    new_item_tablerow_var = raw("new_item_tablerow = \"#{ escape_javascript new_item_tablerow }\";")

    new_item_inputfields = render :partial => 'items/item_inputfields', :locals => { :item => nil, :sort => sort, :articleid => articleid, :quantityid => quantityid, :label => label, :designator => designator, :count => count, :printed_count => printed_count, :price => price, :optionslist => optionslist, :optionsnames => optionsnames, :optionsselect => optionsselect, :comment => nil, :id => nil, :printoptionslist => nil }
    new_item_inputfields_var = raw("\nnew_item_inputfields = \"#{ escape_javascript new_item_inputfields }\";")

    return new_item_tablerow_var + new_item_inputfields_var
  end

end
