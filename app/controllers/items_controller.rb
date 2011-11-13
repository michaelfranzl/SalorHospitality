# coding: utf-8

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

class ItemsController < ApplicationController

  # Return a file that contains all not yet printed Items and all Orders that are marked for printing
  def index
    respond_to do |wants|
      wants.bill {
        items_code = generate_escpos_items
        pending_invoices = Order.find_all_by_print_pending true
        invoices_code = pending_invoices.collect{ |i| generate_escpos_invoice i }.join
        pending_invoices.each { |i| i.update_attribute :print_pending, false }
        render :text => invoices_code + items_code
      }
      wants.html
    end
  end

  #We'll use update for splitting of items into separate orders
  def update
    logger.info "[Split] Started function update (actually split item). I attempt to find item id #{params[:id]}"
    @item = Item.find_by_id(params[:id])
    logger.info "[Split] @item = #{ @item.inspect }"
    raise "Dieses Item wurde nicht mehr gefunden. Oops! Möglicherweise wurde es mehrfach angewählt und es ist bereits in einer anderen Rechnung?" if not @item
    @order = @item.order
    raise "Dieses Item ist nicht mehr mit einer Bestellung verbunden. Oops!" if not @order

    split @item, @order

    @cost_centers = CostCenter.find_all_by_active(true)
    @taxes = Tax.all
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
  end

  # We'll use edit for separation of items
  def edit
    item = Item.find(params[:id])
    separated_item = item.item
    if separated_item.nil?
      separated_item = item.clone
      separated_item.options = item.options
      separated_item.count = 0
      separated_item.item = item
      item.item = separated_item
    end
    item.count -= 1
    item.count == 0 ? item.delete : item.save
    separated_item.count += 1
    separated_item.save
    separated_item.storno_item.update_attribute :count, separated_item.count if separated_item.storno_status != 0
    @order = item.order
  end

  # We'll use this method for storno of items only, we're not going to destroy them really
  # storno_status: 2 = storno clone, 3 = storno original
  #
  def destroy
    i = Item.find_by_id params[:id]
    if i.storno_status == 0
      k = i.clone
      k.options = i.options
      k.storno_status = 2
      k.storno_item = i
      i.storno_item = k
      i.storno_status = 3
      k.save
    else
      i.storno_item.delete
      i.storno_item = nil
      i.storno_status = 0
    end   
    i.save
    @order = i.order
    @order.update_attribute :sum, @order.calculate_sum
    @order.update_attribute :storno_sum, @order.calculate_storno_sum
    render 'edit'
  end

  def rotate_tax
    @item = Item.find_by_id params[:id]
    tax_ids = Tax.all.collect { |t| t.id }
    current_tax_id_index = tax_ids.index @item.tax.id
    next_tax_id = tax_ids.rotate[current_tax_id_index]
    @item.update_attribute :tax_id, next_tax_id
    @item = Item.find_by_id params[:id] # re-read is necessary
  end
  
  def list
    @list = case params[:type]
      when 'preparation' then Item.where("count > preparation_count OR preparation_count IS NULL")
      when 'delivery' then Item.where("preparation_count > delivery_count")
    end
  end
  
  def set_attribute
    @item = Item.find_by_id params[:id]
    @item.update_attribute params[:attribute], params[:value]
    render :nothing => true
  end

  private

    def split(parent_item, parent_order)
      logger.info "[Split] Now I am in the function split with the parameters parent_item #{ parent_item.inspect }"
      logger.info "[Split] parent_order = parent_item.order = #{ parent_order.inspect }"
      logger.info "[Split] parent_order.order.nil? is #{ parent_order.order.nil? }"

      split_order = parent_order.order
      logger.info "[Split] this parent_order's split_order is #{ split_order.inspect }."
      if split_order.nil?
        logger.info "[Split] If: I am going to create a brand new split_order, and make it belong to the parent order"
        Order.transaction do
          split_order = parent_order.clone
          split_order.nr = get_next_unique_and_reused_order_number
          if split_order.nr > @current_company.largest_order_number
            @current_company.update_attribute :largest_order_number, split_order.nr
          end
          sisr1 = split_order.save
          logger.info "[Split] the result of saving split_order is #{ sisr1.inspect } and split_order itself is #{ split_order.inspect }."
          raise "Konnte die abgespaltene Bestellung nicht speichern. Oops!" if not sisr1
          parent_order.update_attribute :order, split_order  # make an association between parent and child
          split_order.update_attribute :order, parent_order  # ... and vice versa
        end
      end

      split_item = parent_item.item
      logger.info "[Split] this parent_item's split_item is #{ split_item.inspect }."
      Item.transaction do
        if split_item.nil?
          logger.info "[Split] Because split_item is nil, we're going to create one."
          split_item = parent_item.clone
          split_item.options = parent_item.options
          split_item.count = 0
          split_item.printed_count = 0
          sisr2 = split_item.save
          logger.info "[Split] The result of saving split_item is #{ sisr2.inspect } and it is #{ split_item.inspect }."
          raise "Konnte das neu erstellte abgespaltene Item nicht speichern. Oops!" if not sisr2
          parent_item.item = split_item # make an association between parent and child
          split_item.item = parent_item # ... and vice versa
        end

        split_item.order = split_order # this is the actual moving to the new order
        if parent_item.count > 0 # proper handling of zero count items
          split_item.count += 1
          split_item.printed_count += 1
        end
        split_item.max_count = parent_item.max_count if split_item.max_count = 0
        sisr3 = split_item.save
        logger.info "[Split] The result of saving split_item is #{ sisr3.inspect } and it is #{ split_item.inspect }."
        raise "Konnte das bereits bestehende abgespaltene Item nicht überspeichern. Oops!" if not sisr3
        if parent_item.count > 0 # proper handling of zero count items
          parent_item.count -= 1
          parent_item.printed_count -= 1
        end
        logger.info "[Split] parent_item.count = #{ parent_item.count.inspect }"
        if parent_item.count == 0
          parent_item.delete
        else
          pisr = parent_item.save
          logger.info "[Split] The result of saving parent_item is #{ pisr.inspect } and it is #{ parent_item.inspect }."
          raise "Konnte das bereits bestehende parent_item nicht überspeichern. Oops!" if not pisr
        end
      end

      logger.info "[Split] parent_order before re-read is #{ parent_order.inspect }."
      parent_order = Order.find(parent_order.id) # re-read
      logger.info "[Split] parent_order after re-read is #{ parent_order.inspect }."
      raise "Konnte parent_order nicht neu laden. Oops!" if not parent_order
      logger.info "[Split] parent_order has #{ parent_order.items.size } items left."

      if parent_order.items.empty?
        parent_order.delete
        logger.info "[Split] deleted parent_order since there were no items left."
        @current_company.unused_order_numbers << parent_order.nr
        @current_company.save
      else
        parent_order.update_attribute :sum, parent_order.calculate_sum
      end
      split_order.update_attribute :sum, split_order.calculate_sum
    end

end
