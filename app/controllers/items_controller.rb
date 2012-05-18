# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class ItemsController < ApplicationController

  # Return a file that contains all not yet printed Items and all Orders that are marked for printing
  def index
    respond_to do |wants|
      wants.bill {
        orders = @current_vendor.orders.existing.where(:print_pending => true)
        tickets = orders.collect{ |o| o.escpos_tickets }.join
        invoices = orders.collect{ |o| o.escpos_invoice[params[:printer_id]] }.join
        orders.update_all :print_pending => false
        render :text => tickets + invoices
      }
      wants.html
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

    @cost_centers = @current_vendor.cost_centers.existing
    @taxes = @current_vendor.taxes.existing
    @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => @order.table_id)
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
    current_tax_id_index = tax_ids.index @item.tax.id
    next_tax_id = tax_ids.rotate[current_tax_id_index]
    @item.update_attribute :tax_id, next_tax_id
    @item.reload # re-read is necessary
  end
  
  def list
    if @current_user.role.permissions.include?('see_item_notifications')
      @list = case params[:scope]
        when 'preparation' then Item.where("preparation_user_id = #{ @current_user.id } AND (count > preparation_count OR preparation_count IS NULL)")
        when 'delivery' then Item.where("delivery_user_id = #{ @current_user.id } AND (preparation_count > delivery_count OR (delivery_count IS NULL AND preparation_count > 0))")
      end
    end
  end
  
  def set_attribute
    @item = get_model
    @item.update_attribute params[:attribute], params[:value]
    render :nothing => true
  end

end
