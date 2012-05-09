# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class OrdersController < ApplicationController

  def index
    @tables = @current_user.tables
    @categories = @current_vendor.categories.positioned
    @users = User.accessible_by(@current_user).active
    session[:admin_interface] = false
  end

  # happens only in invoice_form if user changes CostCenter or Tax of Order
  def update
    @order = get_model
    if params[:order][:tax_id]
      @order.update_attribute :tax_id, params[:order][:tax_id] 
      @order.items.existing.update_all :tax_id => nil
      @orders = @current_vendor.orders.where(:finished => false, :table_id => @order.table_id)
      @cost_centers = @current_vendor.cost_center.existing.active
      @taxes = @current_vendor.taxes.existing
      render 'items/update'
    else
      @order.update_attribute(:cost_center_id, params[:order][:cost_center_id]) if params[:order][:cost_center_id]  
      render :nothing => true
    end
  end

  def show
    if params[:id] != 'last'
      @order = @current_vendor.orders.existing.find(params[:id])
    else
      @order = @current_vendor.orders.existing.find_all_by_finished(true).last
    end
    redirect_to '/' and return if not @order
    @previous_order, @next_order = neighbour_orders(@order)
    respond_to do |wants|
      wants.html
      wants.bill { render :text => generate_escpos_invoice(@order) }
    end
  end

  def by_nr
    @order = @current_vendor.orders.existing.find_by_nr(params[:nr])
    if @order
      redirect_to order_path(@order)
    else
      redirect_to order_path(@current_vendor.orders.existing.last)
    end
  end

  def toggle_admin_interface
    if session[:admin_interface]
      session[:admin_interface] = !session[:admin_interface]
    else
      session[:admin_interface] = true
    end
    @tables = @current_user.tables.existing
  end

  def toggle_tax_colors
    @order = get_model
    if session[:display_tax_colors]
      session[:display_tax_colors] = !session[:display_tax_colors]
    else
      session[:display_tax_colors] = true
    end
    @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => @order.table_id)
    @cost_centers = @current_vendor.cost_centers.existing.active
    @taxes = @current_vendor.taxes.existing
    render 'items/update'
  end

  def print
  end

  def print_and_finish
    @order = get_model
    was_finished = @order.finished
    @order.finish unless @order.finished
    @order.user = @current_user
    @order.printed_from = "#{ request.remote_ip } -> #{ params[:port] }" if params[:port] != '0'
    @order.save
    @order.reload

    if params[:port].to_i != 0
      if local_variant?
        # print immediately
        selected_printer = @current_vendor.vendor_printers.existing.find_by_id(params[:port].to_i)
        @order.print_invoice(selected_printer)
      else
        # print later
        @order.update_attribute :print_pending, true
      end
    end

    @orders = @current_vendor.orders.existing.where(:table_id => @order.table, :finished => false)
    @order.table.update_attribute :user, nil if @orders.empty?
    @cost_centers = @current_vendor.cost_centers.existing.active
    @taxes = @current_vendor.taxes.existing
    respond_to do |wants|
      wants.js {
        if was_finished
          # is the case for storno_form
          render :nothing => true
        elsif @orders.empty?
          # is the case for invoice_form
          @tables = @current_user.tables.existing
          render :js => "go_to(#{@order.table_id},'tables');"
        else
          # is the case for invoice_form
          render 'go_to_invoice_form'
        end
      }
    end
  end

  def storno
    @order = get_model
  end

  def update_ajax
    @cost_centers = @current_vendor.cost_centers.existing.active

    if params[:order][:id].empty?
      # The AJAX load on the client side has not succeeded before user submitted the order form.
      # In this case, simply select the first order on the table the user had selected.
      @order = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:order][:table_id]).first
    else
      # The AJAX load on the client side has succeeded and we know the order ID.
      @order = @current_vendor.orders.existing.find_by_id params[:order][:id]
    end

    if @order
      @order.update_attributes params[:order]
      params[:items].to_a.each do |item_params|
        item_id = item_params[1][:id]
        if item_id
          item_params[1].delete(:id)
          item = Item.find_by_id(item_id)
          item.update_attributes(item_params[1])
          item.calculate_totals
        else
          new_item = Item.new(item_params[1])
          new_item.cost_center = @order.cost_center
          new_item.calculate_totals
          @order.items << new_item
        end
      end
    else
      @order = Order.new params[:order]
      @order.nr = @current_vendor.get_unique_order_number
      @order.cost_center = @current_vendor.cost_centers.existing.active.first
      @order.vendor = @current_vendor
      @order.company = @current_company
      params[:items].to_a.each do |item_params|
        new_item = Item.new(item_params[1])
        new_item.cost_center = @order.cost_center
        new_item.calculate_totals
        @order.items << new_item
      end
    end

    @order.table.user = @current_user
    @order.table.save
    @order.user = @current_user

    @order.items.where( :user_id => nil, :preparation_user_id => nil, :delivery_user_id => nil ).each do |i|
      i.update_attributes :user_id => @current_user.id, :vendor_id => @current_vendor.id, :company_id => @current_company.id, :preparation_user_id => i.article.category.preparation_user_id, :delivery_user_id => @current_user.id
    end

    if @order.nr > @current_vendor.largest_order_number
      @current_vendor.update_attribute :largest_order_number, @order.nr 
    end

    @order.calculate_totals

    if @order.items.existing.size.zero?
      @current_vendor.unused_order_numbers << @order.nr
      @current_vendor.save
      @order.hidden = true
      @order.nr = nil
      @order.table.user = nil
      @order.table.save
      @tables = @current_user.tables.existing
      @order.save
      render :nothing => true and return
    end

    @order.regroup
    @order.print_tickets if local_variant?

    @taxes = @current_vendor.taxes.existing
    @tables = @current_user.tables.existing.where(:enabled => true)
    case params[:state][:target]
      when 'tables'
        case params[:state][:action]
          when 'send'
            render :nothing => true
          when 'move'
            @order.move params[:state][:target_table_id]
            render :nothing => true
        end
      when 'invoice'
        @orders = @current_vendor.orders.existing.where(:table_id => @order.table.id, :finished => false)
        session[:display_tax_colors] = @current_vendor.country == 'de' or @current_vendor.country == 'cc'
        render 'go_to_invoice_form'
      else
        render :nothing => true
    end
  end

  def last_invoices
    @unsettled_orders = @current_vendor.orders.existing.where(:settlement_id => nil, :finished => true, :user_id => @current_user.id)
    if @current_user.role.permissions.include? 'finish_all_settlements'
      @users = @current_vendor.users
    elsif @current_user.role.permissions.include? 'finish_own_settlement'
      @users = [@current_user]
    else
      @users = []
    end
  end

  private

    def neighbour_orders(order)
      orders = @current_vendor.orders.existing.where(:finished => true)
      idx = orders.index(order)
      previous_order = orders[idx-1] if idx
      previous_order = order if previous_order.nil?
      next_order = orders[idx+1] if idx
      next_order = order if next_order.nil?
      return previous_order, next_order
    end

    def reduce_stocks(order)
      order.items.exisiting.each do |item|
        item.article.ingredients.each do |ingredient|
          ingredient.stock.balance -= item.count * ingredient.amount
          ingredient.stock.save
        end
      end
    end

end
