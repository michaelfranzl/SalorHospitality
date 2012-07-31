# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class OrdersController < ApplicationController

  def index
    @tables = @current_user.tables.where(:vendor_id => @current_vendor).existing
    @categories = @current_vendor.categories.positioned
    @users = User.accessible_by(@current_user).active
    session[:admin_interface] = false
  end

  def show
    if params[:id] != 'last'
      @order = @current_vendor.orders.existing.find(params[:id])
    else
      @order = @current_vendor.orders.existing.find_all_by_paid(true).last
    end
    redirect_to '/' and return if not @order
    @previous_order, @next_order = neighbour_models('orders',@order)
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
    @tables = @current_user.tables.where(:vendor_id => @current_vendor).existing
  end

  def refund
    @order = get_model
  end

  def update_ajax
    #puts "XXXXXXXXXXXXX #{params[:currentview]}"
    #puts "XXXXXXXXXXXXX #{params[:jsaction]}"
    case params[:currentview]
      # this action is for simple pushing of a model to the server and
      # getting a json object back.
      when 'push'
        if params[:relation] then
          @model = @current_vendor.send(params[:relation]).existing.find_by_id(params[:id])
          @model.update_attributes(params[:model])
          render :json => @model and return
        end
      when 'invoice_paper', 'refund'
        @order = get_model
        case params['jsaction']
          when 'just_print'
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            render :nothing => true and return
          when 'mark_print_pending'
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
            render :nothing => true and return
        end
      when 'invoice'
        @order = get_order
        case params['jsaction']
          when 'display_tax_colors'
            if session[:display_tax_colors]
              session[:display_tax_colors] = !session[:display_tax_colors]
            else
              session[:display_tax_colors] = true
            end
            prepare_objects_for_invoice
            render 'items/update' and return
          when 'mass_assign_tax'
            #@order.update_attribute :tax_id, params[:tax_id] 
            tax = @current_vendor.taxes.find_by_id(params[:tax_id])
            @order.items.existing.each do |item|
              item.taxes = { tax.id => { :percent => tax.percent, :sum => (item.sum * (tax.percent / 100.0)).round(2) }}
              item.save
            end
            @order.calculate_totals
            prepare_objects_for_invoice
            render 'items/update' and return
          when 'change_cost_center'
            @order.update_attribute(:cost_center_id, params[:cost_center_id])
            render :nothing => true and return
          when 'assign_to_booking'
            @booking = @current_vendor.bookings.find_by_id(params[:booking_id])
            @order.update_attributes(:booking_id => @booking.id)
            @order.finish
            @booking.calculate_totals
            if mobile?              
              redirect_from_invoice and return
            else
              render :js => "route('booking',#{@booking.id});" and return
            end
          when 'pay_and_print'
            @order.pay
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            redirect_from_invoice and return
          when 'pay_and_print_pending'
            @order.pay
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
            redirect_from_invoice and return
          when 'pay_and_no_print'
            @order.pay
            redirect_from_invoice and return
        end
      when 'table'
        case params['jsaction']
          when 'send'
            get_order
            @order.calculate_totals
            @order.regroup
            @order.update_associations(@current_user)
            if @order.items.existing.size.zero?
              @order.hide(@current_user.id)
              @order.unlink
            end
            if @order.booking
              @order.update_associations(@current_user)
              @order.finish
              @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:model][:table_id])
              if @orders.empty?
                @order.table.update_attribute :user, nil
              end
            end
            render :nothing => true and return if @order.hidden
            render :js => "route('booking',#{@order.booking.id});" and return if @order.booking
            case params[:target]
              when 'tables' then
                @order.print(['tickets'])
                render :nothing => true and return
              when 'table' then
                @order.pay
                @order.print(['tickets'])
                @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:model][:table_id])
                if @orders.empty?
                  @order.table.update_attribute :user, nil
                  render :js => "route('table',#{params[:model][:table_id]});" and return
                else
                  render :js => "route('tables',#{params[:model][:table_id]});" and return
                end
              when 'invoice' then
                @order.print(['tickets'])
                prepare_objects_for_invoice
                render 'go_to_invoice_form' and return
            end
          when 'send_and_print'
            get_order
            @order.calculate_totals
            @order.regroup
            @order.update_associations(@current_user)
            @order.hide(@current_user.id) if @order.items.existing.size.zero?
            if @current_company.mode == 'local' and not @order.hidden
              @order.print(['tickets','receipt'], @current_vendor.vendor_printers.existing.first)
            end
            @order.finish
            @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => @order.table.id)
            if @orders.empty?
              @order.table.update_attribute :user, nil
              render :js => "route('table', #{@order.table.id});" and return
            else
              render :js => "route('tables', #{@order.table.id});" and return
            end
          when 'move'
            get_order
            @order.move(params[:target_table_id])
            @order.print(['tickets'])
            #@order.hide(@current_user.id) if @order.items.existing.size.zero?
            render :js => "route('tables', #{@order.table.id});" and return
        end
      when 'room'
        case params['jsaction']
          when 'send'
            get_booking
            @booking.update_associations(@current_user)
            @booking.calculate_totals
            unless @booking.booking_items.existing.any?
              @booking.hide(@current_user.id)
            end
            render :js => "route('rooms', '#{@booking.room_id}', 'update_bookings', #{@booking.to_json })" and return
          when 'pay'
            get_booking
            @booking.update_associations(@current_user)
            @booking.calculate_totals
            @booking.pay
            render :js => "route('rooms');" and return
          when 'send_and_go_to_table'
            get_booking
            @booking.update_associations(@current_user)
            @booking.calculate_totals
            render :js => "submit_json.model.booking_id = #{ @booking.id }" and return # the switch to the table happens in the JS route function from where this was called
          when 'send_and_redirect_to_invoice'
            get_booking
            @booking.update_associations(@current_user)
            @booking.calculate_totals
            render :js => "window.location = '/bookings/#{ @booking.id }';" and return
          when 'pay_and_redirect_to_invoice'
            get_booking
            @booking.update_associations(@current_user)
            @booking.calculate_totals
            @booking.pay
            render :js => "window.location = '/bookings/#{ @booking.id }';" and return
            
        end
      when 'rooms'
        case params['jsaction']
          when 'move_booking'
            @booking = @current_vendor.bookings.find_by_id(params[:model][:id])
            if @booking
              @booking.update_attribute(:room_id,params[:model][:room_id]) 
              render :js => "route('rooms', '#{@booking.room_id}', 'update_bookings', #{@booking.to_json })" and return
            else
              render :text => 'Epic Fail' and return
            end
        end
          
    end
  end

  def last_invoices
    @unsettled_orders = @current_vendor.orders.existing.where(:settlement_id => nil, :finished => true, :user_id => @current_user.id).limit(5)
    if @current_user.role.permissions.include? 'finish_all_settlements'
      @users = @current_vendor.users
    elsif @current_user.role.permissions.include? 'finish_own_settlement'
      @users = [@current_user]
    else
      @users = []
    end
  end

  private

    def redirect_from_invoice
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => @order.table_id)
      if @orders.empty?
        @order.table.update_attribute :user, nil if @orders.empty?
        render :js => "route('tables');" and return
      else
        prepare_objects_for_invoice
        render 'go_to_invoice_form' and return
      end
    end

    def get_order
      if params[:id]
        @order = get_model
      elsif params[:model] and params[:model][:table_id]
        # Reuse the order on table if possible
        @order = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:model][:table_id]).first
      else
        raise "params[:model][:table_id] was not set. This is probably a JS issue and should never happen."
      end
      if @order
        @order.update_from_params(params)
      else
        @order = Order.create_from_params(params, @current_vendor, @current_user)
        @order.set_nr
      end
      return @order
    end

    def get_booking
      @booking = Booking.accessible_by(@current_user).existing.find_by_id(params[:id]) if params[:id]
      if @booking
        @booking.update_from_params(params)
      else
        @booking = Booking.create_from_params(params, @current_vendor, @current_user)
        @booking.set_nr
      end
      return @booking
    end
end
