# coding: utf-8
class ItemsController < ApplicationController

  def index
    respond_to do |wants|
      wants.bon { render :text => generate_escpos_items(:drink) }
    end
  end

  #We'll use update for splitting of items into separate orders
  def update
    logger.info "XXX Started function update (actually split item). I attempt to find item id #{params[:id]}"
    @item = Item.find_by_id(params[:id])
    logger.info "XXX @item = #{ @item.inspect }"
    raise "Dieses Item wurde nicht mehr gefunden. Oops! Möglicherweise wurde es mehrfach angewählt und es ist bereits in einer anderen Rechnung?" if not @item
    @order = @item.order
    raise "Dieses Item ist nicht mehr mit einer Bestellung verbunden. Oops!" if not @order

    split @item, @order

    @cost_centers = CostCenter.find_all_by_active(true)
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
  end

  # We'll use edit for separation of items
  def edit
    item = Item.find(params[:id])
    separated_item = item.item
    if separated_item.nil?
      separated_item = item.clone
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

  # We'll use destroy for storno of items
  # storno_status: 2 = storno clone, 3 = storno original
  #
  def destroy
    i = Item.find_by_id params[:id]
    if i.storno_status == 0
      k = i.clone
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
    render 'edit'
  end

  private

    def split(parent_item, parent_order)
      logger.info "XXX Now I am in the function split with the parameters parent_item #{ parent_item.inspect }"
      logger.info "XXX parent_order = parent_item.order = #{ parent_order.inspect }"
      logger.info "XXX parent_order.order.nil? is #{ parent_order.order.nil? }"

      split_order = parent_order.order
      logger.info "XXX this parent_order's split_order is #{ split_order.inspect }."
      if split_order.nil?
        logger.info "XXX If: I am going to create a brand new split_order, and make it belong to the parent order"
        split_order = parent_order.clone
        split_order.nr = get_next_unique_and_reused_order_number
        sisr1 = split_order.save
        logger.info "XXX the result of saving split_order is #{ sisr1.inspect } and split_order itself is #{ split_order.inspect }."
        raise "Konnte die abgespaltene Bestellung nicht speichern. Oops!" if not sisr1
        parent_order.update_attribute :order, split_order  # make an association between parent and child
        split_order.update_attribute :order, parent_order  # ... and vice versa
      end

      split_item = parent_item.item
      logger.info "XXX this parent_item's split_item is #{ split_item.inspect }."
      if split_item.nil?
        logger.info "XXX Because split_item is nil, we're going to create one."
        split_item = parent_item.clone
        split_item.count = 0
        split_item.printed_count = 0
        sisr2 = split_item.save
        logger.info "XXX The result of saving split_item is #{ sisr2.inspect } and it is #{ split_item.inspect }."
        raise "Konnte das neu erstellte abgespaltene Item nicht speichern. Oops!" if not sisr2
        parent_item.item = split_item # make an association between parent and child
        split_item.item = parent_item # ... and vice versa
      end

      split_item.order = split_order # this is the actual moving to the new order
      split_item.count += 1
      split_item.printed_count += 1
      sisr3 = split_item.save
      logger.info "XXX The result of saving split_item is #{ sisr3.inspect } and it is #{ split_item.inspect }."
      raise "Konnte das bereits bestehende abgespaltene Item nicht überspeichern. Oops!" if not sisr3
      parent_item.count -= 1
      parent_item.printed_count -= 1
      logger.info "XXX parent_item.count = #{ parent_item.count.inspect }"
      if parent_item.count == 0 
        parent_item.delete
      else
        pisr = parent_item.save
        logger.info "XXX The result of saving parent_item is #{ pisr.inspect } and it is #{ parent_item.inspect }."
        raise "Konnte das bereits bestehende parent_item nicht überspeichern. Oops!" if not pisr
      end

      logger.info "XXX parent_order before re-read is #{ parent_order.inspect }."
      parent_order = Order.find(parent_order.id) # re-read
      logger.info "XXX parent_order after re-read is #{ parent_order.inspect }."
      raise "Konnte parent_order nicht neu laden. Oops!" if not parent_order
      logger.info "XXX parent_order has #{ parent_order.items.size } items left."

      if parent_order.items.empty?
        parent_order.delete
        logger.info "XXX deleted parent_order since there were no items left."
        MyGlobals::unused_order_numbers << parent_order.nr
      else
        parent_order.update_attribute( :sum, calculate_order_sum(parent_order) )
      end
      split_order.update_attribute( :sum, calculate_order_sum(split_order) )
    end

end
