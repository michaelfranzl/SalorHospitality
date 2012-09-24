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

  #We'll use update for splitting of items into separate orders
  def update
    @item = get_model
    case params[:jsaction]
    when 'split'
      @item.split if @item
      @order = @item.order
      prepare_objects_for_invoice
      render :update and return
    when 'rotate_tax'
      tax_ids = @current_vendor.taxes.existing.collect { |t| t.id }
      current_item_tax = @current_vendor.taxes.find_by_id(@item.taxes.keys.first)
      current_tax_id_index = tax_ids.index current_item_tax.id
      next_tax_id = tax_ids.rotate[current_tax_id_index]
      next_tax = @current_vendor.taxes.find_by_id(next_tax_id)
      @item.calculate_taxes([next_tax])
      render :rotate_tax and return
    end
    render :nothing => true
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
      render :nothing => true and return unless @current_user.role.permissions.include?('see_item_notifications_vendor')
      items[:preparation] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (count > preparation_count OR preparation_count IS NULL)")
      items[:delivery] = Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
    elsif params[:type] == 'user' 
      render :nothing => true and return unless (@current_user.role.permissions.include?('see_item_notifications_delivery') or @current_user.role.permissions.include?('see_item_notifications_preparation'))
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
