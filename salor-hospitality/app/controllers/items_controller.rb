# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class ItemsController < ApplicationController

  def show
    @item = get_model
    respond_to do |wants|
      wants.svg
      wants.html { redirect_to orders_path }
    end
  end

  def split
    @item = []
    params['split_items_hash'].each do |k,v|
      @item = get_model(k.to_i)
      @item.split(v['split_count'].to_i) if @item
    end
    render_invoice_form(@item.order.table)
  end
  
  def rotate_tax
    @item = get_model
    @item.rotate_tax
    render_invoice_form(@item.order.table) 
  end

  # We'll use edit for separation of items in the refund form
  def edit
    item = get_model
    item.separate
    @order = item.order
  end

  def destroy
    item = get_model
    item.refund(@current_user)
    @order = item.order
    render 'edit'
  end
  
  def list
    items = {}
    items_json_string = {}
    if (params[:type] == 'vendor')
      items[:preparation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (count > preparation_count OR preparation_count IS NULL)")
      items[:delivery] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
    elsif params[:type] == 'user' 
      items[:preparation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND preparation_user_id = #{ @current_user.id } AND (count > preparation_count OR preparation_count IS NULL)")
      items[:delivery] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND delivery_user_id = #{ @current_user.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
    end
    [:preparation, :delivery].each do |scope|
      items_json_string[scope] = items[scope].collect { |i|
        label = i.quantity_id ? "#{ i.quantity.prefix } #{ i.article.name[0..15] } #{ i.quantity.postfix }#{ i.formatted_comment }#{ i.compose_option_names_without_price }" : "#{ i.article.name[0..15] }#{ i.formatted_comment }#{ i.compose_option_names_without_price}"

        "\"#{i.id}\":{\"id\":#{i.id},\"tid\":#{i.order.table_id},\"cid\":#{i.category_id},\"aid\":#{i.article_id},\"qid\":#{i.quantity_id ? i.quantity_id : 'null'},\"preparation_uid\":#{i.preparation_user_id ? i.preparation_user_id : 'null'},\"delivery_uid\":#{i.delivery_user_id ? i.delivery_user_id : 'null'},\"preparation_c\":#{i.preparation_count ? i.preparation_count : 'null'},\"delivery_c\":#{i.delivery_count ? i.delivery_count : 'null'},\"c\":#{i.count},\"s\":#{!i.scribe.nil?},\"l\":\"#{label}\",\"t\":\"#{i.created_at.strftime('%H:%M:%S')}\"}"
      }.join(',').gsub("\n", '\n')
    end
    render :js => "{\"preparation\":{#{items_json_string[:preparation]}}, \"delivery\":{#{items_json_string[:delivery]}}}"
  end
  
  def set_attribute
    @item = get_model
    @item.update_attribute params[:attribute], params[:value]
    render :nothing => true
  end
  


end
