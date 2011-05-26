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
# You should have received a copy of the GNU Affero General Publwic License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class OrdersController < ApplicationController

  def index
    @tables = Table.all
    @categories = Category.find(:all, :order => :sort_order)
    @users = User.all
    session[:admin_interface] = !mobile? # on workstation, switch admin panel on per default
  end

  # happens only in invoice_form if user changes CostCenter or Tax of Order
  def update
    @order = Order.find_by_id params[:id]
    if params[:order][:tax_id]
      @order.update_attribute :tax_id, params[:order][:tax_id] 
      @order.items.each { |i| i.update_attribute :tax_id, nil }
      @orders = Order.find_all_by_finished(false, :conditions => { :table_id => @order.table_id })
      @cost_centers = CostCenter.all
      @taxes = Tax.all
      render 'items/update'
    else
      @order.update_attribute(:cost_center_id, params[:order][:cost_center_id]) if params[:order][:cost_center_id]  
      render :nothing => true
    end
  end

  def edit
    @order = Order.find_by_id params[:id]
    @table = @order.table
    render 'orders/go_to_order_form'
  end

  def show
    if params[:id] != 'last'
      @order = Order.find(params[:id])
    else
      @order = Order.find_all_by_finished(true).last
    end
    redirect_to '/' and return if not @order
    @previous_order, @next_order = neighbour_orders(@order)
    respond_to do |wants|
      wants.html
      wants.bill { render :text => generate_escpos_invoice(@order) }
    end
  end

  def unsettled
    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
    flash[:notice] = t(:there_are_no_open_settlements) if @unsettled_users.empty?
  end

  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    @tables = Table.all
  end

  def toggle_tax_colors
    if session[:display_tax_colors]
      session[:display_tax_colors] = !session[:display_tax_colors]
    else
      session[:display_tax_colors] = true
    end
    @orders = Order.find_all_by_finished(false, :conditions => { :table_id => Order.find_by_id(params[:id]).table_id })
    @cost_centers = CostCenter.all
    @taxes = Tax.all
    render 'items/update'
  end

  def print_and_finish
    @order = Order.find params[:id]

    @current_company.largest_order_number = @order.nr if @order.nr > @current_company.largest_order_number

    if not @order.finished and mobile?
      @order.user = @current_user
      @order.created_at = Time.now
    end

    if @order.order # unlink any parent relationships of Order and Item
      @order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.items.each do |item|
        item.item.update_attribute( :item_id, nil ) if item.item
        item.update_attribute( :item_id, nil )
      end
      @order.order.update_attribute( :order_id, nil )
      @order.update_attribute( :order_id, nil )
    end

    if params[:port].to_i != 0
      if local_variant?
        # print immediately
        selected_printer = VendorPrinter.find_by_id(params[:port].to_i)
        printer_id = selected_printer.id if selected_printer
        all_printers = initialize_printers
        text = generate_escpos_invoice(@order)
        print(all_printers, printer_id, text)
        close_printers(all_printers)
      else
        # print later
        @order.update_attribute :print_pending, true
      end
    end

    justfinished = false
    if not @order.finished
      @order.finished = true
      @order.printed_from = "#{ request.remote_ip } -> #{ params[:port] }"
      justfinished = true
      @order.save
    end

    @orders = Order.find(:all, :conditions => { :table_id => @order.table, :finished => false })
    @order.table.update_attribute :user, nil if @orders.empty?
    @cost_centers = CostCenter.find_all_by_active(true)
    @taxes = Tax.all

    respond_to do |wants|
      wants.html { redirect_to order_path @order }
      wants.js {
        if not justfinished
          render :nothing => true
        elsif not @orders.empty?
          render('go_to_invoice_form')
        else
          @tables = Table.all
          render('go_to_tables')
        end
      }
    end
  end

  def storno
    @order = Order.find_by_id params[:id]
  end

  def go_to_order_form # to be called only with /id
    @order = Order.find(params[:id])
    @table = @order.table
    @cost_centers = CostCenter.find_all_by_active(true)
    render 'go_to_order_form'
  end

  def receive_order_attributes_ajax
    @cost_centers = CostCenter.find_all_by_active true

    if params[:order][:id] == 'add_offline_items_to_order'
      @order = Order.find(:all, :conditions => { :finished => false, :table_id => params[:order][:table_id] }).first
    elsif not params[:order][:id].empty?
      @order = Order.find_by_id params[:order][:id]
    end

    if @order
      # similar to orders#update
      @order.update_attributes params[:order]
    else
      # similar to orders#create
      @order = Order.new params[:order]
      @order.nr = get_next_unique_and_reused_order_number
      @order.credit = Order.last ? Order.last.credit - 1 : BillGastro::Application::INITIAL_CREDITS
      @order.cost_center = @cost_centers.first
    end
    @order.sum = calculate_order_sum @order
    @order.table.update_attribute :user, @order.user
    @order.save

    if @order.nr > @current_company.largest_order_number
      @current_company.update_attribute :largest_order_number, @order.nr 
    end

    @tables = Table.all

    if @order.items.size.zero?
      @current_company.unused_order_numbers << @order.nr
      @current_company.save
      @order.delete
      @order.table.update_attribute :user, nil
      render('go_to_tables') and return
    end

    group_identical_items @order

    if local_variant?
      # print
      printers = initialize_printers
      printers.each do |id, params|
        normal   = generate_escpos_items @order, id, 0
        takeaway = generate_escpos_items @order, id, 1
        print printers, id, normal
        print printers, id, takeaway
      end
      close_printers printers
    end

    @taxes = Tax.all

    case params[:order_action]
      when 'save_and_go_to_tables'
        render 'go_to_tables'
      when 'save_and_go_to_invoice'
        @orders = Order.find(:all, :conditions => { :table_id => @order.table.id, :finished => false })
        session[:display_tax_colors] = true if @current_company.country == 'gn'
        render 'go_to_invoice_form'
      when 'move_order_to_table'
        move_order_to_table @order, params[:target_table]
        @tables = Table.all
        render 'go_to_tables'
    end
  end

  def last_invoices
    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true, :user_id => @current_user.id })
    @sum = @unsettled_orders.sum(&:sum)
  end

  private

    def move_order_to_table(order, target_table_id)
      target_order = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false }).first
      if target_order
        # merge orders
        Item.transaction do
          order.items.each do |i|
            i.update_attribute :order, target_order
          end
        end

        target_order.reload
        target_order.sum = calculate_order_sum(target_order)
        target_order.order_id = nil
        target_order.save
        group_identical_items(target_order)

        order.reload # important before destroying, otherwise rails deletes all no longer associated items because of has_many :items, :dependent => :destroy
        order.destroy
      else
        # just move whole order to empty table
        order.update_attribute :table_id, target_table_id
      end

      # unlink in case it was an splitted Item/Order
      if order.order
        Item.transaction do
          order.order.items.each do |i|
            i.update_attribute :item_id, nil
          end
        end

        Item.transaction do
          order.items.each do |i|
            i.update_attribute :item_id, nil
          end
        end

        order.update_attribute :order_id, nil
        order.order.update_attribute :order_id, nil
      end

      # update table users and colors
      this_table = order.table
      unfinished_orders_on_this_table = Order.find(:all, :conditions => { :table_id => this_table.id, :finished => false })
      this_table.update_attribute :user, nil if unfinished_orders_on_this_table.empty?
      unfinished_orders_on_target_table = Order.find(:all, :conditions => { :table_id => target_table_id, :finished => false })
      Table.find(target_table_id).update_attribute :user, order.user
    end

    def group_identical_items(o)
      items = o.items
      n = items.size - 1
      0.upto(n-1) do |i|
        (i+1).upto(n) do |j|
          Item.transaction do
            if (items[i].article_id  == items[j].article_id and
                items[i].quantity_id == items[j].quantity_id and
                items[i].price       == items[j].price and
                items[i].comment     == items[j].comment
               )
              items[i].count += items[j].count
              items[i].printed_count += items[j].printed_count
              result = items[i].save
              raise "Couldn't save item during grouping. Oops!" if not result
              items[j].destroy
            end
          end
        end
      end
    end

    def neighbour_orders(order)
      orders = Order.find_all_by_finished(true)
      idx = orders.index(order)
      previous_order = orders[idx-1]
      previous_order = order if previous_order.nil?
      next_order = orders[idx+1]
      next_order = order if next_order.nil?
      return previous_order, next_order
    end

    def reduce_stocks(order)
      order.items.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end

end
