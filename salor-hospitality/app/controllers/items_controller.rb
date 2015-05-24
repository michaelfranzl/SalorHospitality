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
    h = History.new
    h.action_taken = 'ItemsController#split'
    h.changes_made = params.to_s
    h.save
    if params['split_items_hash']
      order = @current_vendor.orders.existing.find_by_id(params[:order_id])
      render :nothing => true and return unless order
      
      if order.finished == true
        render :js => "order_already_finished();"
        return
      end
      
      Item.split_items(params['split_items_hash'])
      table = order.table
      render_invoice_form(table)
      return
    end
    render :nothing => true
    return
  end
  
  def rotate_tax
    @item = get_model
    @item.rotate_tax
    render_invoice_form(@item.order.table) 
  end

  # We'll use edit for separation of items in the refund form
  def edit
    h = History.new
    h.action_taken = 'ItemsController#separate'
    h.changes_made = params.to_s
    h.save
    item = get_model
    item.separate
    @order = item.order
  end

  def list
    items = {}
    items_json_string = {}
    
    if @current_user.confirmation_user
      # unlike the following queries, this one is always global, not assigned to a single user, i.e. returns all confirmations for the vendor.
      items[:confirmation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (count > confirmation_count OR confirmation_count IS NULL)")
    else
      items[:confirmation] = []
    end
    
    #Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = 1 and vendor_id = 1 AND (confirmation_count > preparation_count OR (preparation_count IS NULL AND confirmation_count > 0))").count
    
    #Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = 1 and vendor_id = 1 AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))").count
    
    #Item.connection.execute("update items set preparation_count = count, delivery_count = count, confirmation_count = count")
      
    if (params[:type] == 'vendor')
      items[:preparation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (confirmation_count > preparation_count OR (preparation_count IS NULL AND confirmation_count > 0))")
      items[:delivery] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
    elsif params[:type] == 'user'
      items[:preparation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND preparation_user_id = #{ @current_user.id } AND (confirmation_count > preparation_count OR (preparation_count IS NULL AND confirmation_count > 0))")
      items[:delivery] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND delivery_user_id = #{ @current_user.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
    end
    [:confirmation, :preparation, :delivery].each do |scope|
      items_json_string[scope] = items[scope].collect { |i|
        label = i.quantity_id ? "#{ i.quantity.prefix } #{ i.article.name[0..15] } #{ i.quantity.postfix }#{ i.formatted_comment }#{ i.compose_option_names_without_price }" : "#{ i.article.name[0..15] }#{ i.formatted_comment }#{ i.compose_option_names_without_price}"

        "\"#{i.id}\":{\"id\":#{i.id},\"tid\":#{i.order.table_id},\"cid\":#{i.category_id},\"aid\":#{i.article_id},\"qid\":#{i.quantity_id ? i.quantity_id : 'null'},\"preparation_uid\":#{i.preparation_user_id ? i.preparation_user_id : 'null'},\"delivery_uid\":#{i.delivery_user_id ? i.delivery_user_id : 'null'},\"confirmation_c\":#{i.confirmation_count ? i.confirmation_count : 'null'},\"preparation_c\":#{i.preparation_count ? i.preparation_count : 'null'},\"delivery_c\":#{i.delivery_count ? i.delivery_count : 'null'},\"c\":#{i.count},\"s\":#{!i.scribe.nil?},\"l\":\"#{label}\",\"t\":\"#{i.created_at.strftime('%H:%M:%S')}\"}"
      }.join(',').gsub("\n", '\n')
    end
    render :js => "{\"confirmation\":{#{items_json_string[:confirmation]}}, \"preparation\":{#{items_json_string[:preparation]}}, \"delivery\":{#{items_json_string[:delivery]}}}"
  end
  
  def set_attribute
    @item = get_model
    @item.update_attribute params[:attribute], params[:value]
    render :nothing => true
  end
  


end
