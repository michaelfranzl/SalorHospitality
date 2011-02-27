class ItemsController < ApplicationController

  def index
    respond_to do |wants|
      wants.bon { render :text => generate_escpos_items(:drink) }
    end
  end

  def update
    @item_to_split = Item.find_by_id(params[:id]) # find item on which was clicked
    @order = @item_to_split.order
    @cost_centers = CostCenter.find_all_by_active(true)
    make_split_invoice(@order, @item_to_split)
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
    render 'split_invoice'
  end

  private

    def make_split_invoice(parent_order, split_item)

      return if split_item.nil?

      if parent_order.order # if there already exists one child order, use it for the split invoice
        split_invoice = parent_order.order
      else # create a brand new split invoice, and make it belong to the parent order
        split_invoice = parent_order.clone
        split_invoice.nr = get_next_unique_and_reused_order_number
        split_invoice.save
        parent_order.order = split_invoice  # make an association between parent and child
        split_invoice.order = parent_order  # ... and vice versa
      end

      parent_item = split_item
      if parent_item.item
        split_item = parent_item.item
      else
        split_item = parent_item.clone
        split_item.count = 0
        split_item.printed_count = 0
        split_item.save
        parent_item.item = split_item # make an association between parent and child
        split_item.item = parent_item # ... and vice versa
      end
      split_item.order = split_invoice # this is the actual moving to the new order
      split_item.count += 1
      split_item.printed_count += 1
      split_item.save
      parent_item.count -= 1
      parent_item.printed_count -= 1
      parent_item.count == 0 ? parent_item.delete : parent_item.save

      parent_order = Order.find(parent_order.id) # re-read

      if parent_order.items.empty?
        MyGlobals::unused_order_numbers << parent_order.nr
        parent_order.delete
      end

      parent_order.update_attribute( :sum, calculate_order_sum(parent_order) ) if not parent_order.items.empty?
      split_invoice.update_attribute( :sum, calculate_order_sum(split_invoice) )
    end

end
