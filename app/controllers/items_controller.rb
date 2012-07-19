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
    logger.info "[Split] Started function update (actually split item). I attempt to find item id #{params[:id]}"
    @item = get_model
    logger.info "[Split] @item = #{ @item.inspect }"
    raise "Dieses Item wurde nicht mehr gefunden. Oops! Möglicherweise wurde es mehrfach angewählt und es ist bereits in einer anderen Rechnung?" if not @item
    @order = @item.order
    raise "Dieses Item ist nicht mehr mit einer Bestellung verbunden. Oops!" if not @order

    @item.split

    prepare_objects_for_invoice
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

  def rotate_tax
    @item = get_model
    tax_ids = @current_vendor.taxes.existing.collect { |t| t.id }
    current_item_tax = @current_vendor.taxes.find_by_id(@item.taxes.keys.first)
    current_tax_id_index = tax_ids.index current_item_tax.id
    next_tax_id = tax_ids.rotate[current_tax_id_index]
    next_tax = @current_vendor.taxes.find_by_id(next_tax_id)
    @item.update_attribute :taxes, {next_tax.id => {:percent => next_tax.percent, :sum => (@item.sum * (next_tax.percent/100.0).round(2))}}
    @item.reload # re-read is necessary
  end
  
  def list
    if @current_user.role.permissions.include?('see_item_notifications')
      @list = case params[:scope]
        when 'preparation' then Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND preparation_user_id = #{ @current_user.id } AND (count > preparation_count OR preparation_count IS NULL)")
        when 'delivery' then Item.where("(hidden = FALSE OR hidden IS NULL) AND company_id = #{ @current_company.id } and vendor_id = #{ @current_vendor.id } AND delivery_user_id = #{ @current_user.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
      end
    end
  end
  
  def set_attribute
    @item = get_model
    @item.update_attribute params[:attribute], params[:value]
    render :nothing => true
  end

end
