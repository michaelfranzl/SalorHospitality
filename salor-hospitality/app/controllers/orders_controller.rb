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
      #===============CURRENTVIEW==================
      # this action is for simple writing of any model to the server and getting a Model object back. TODO: This should actually go into a separate controller, like application controller.
      when 'push'
        if params[:relation] then
          @model = @current_vendor.send(params[:relation]).existing.find_by_id(params[:id])
          @model.update_attributes(params[:model])
          render :json => @model and return
        end
      #===============CURRENTVIEW==================
      when 'invoice_paper', 'refund'
        @order = get_model
        case params['jsaction']
          #----------jsaction----------
          when 'just_print'
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            render :nothing => true and return
          #----------jsaction----------
          when 'mark_print_pending'
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
            render :nothing => true and return
        end
      #===============CURRENTVIEW==================
      when 'invoice'
        @order = get_order
        case params['jsaction']
          #----------jsaction----------
          when 'move'
            former_table = @order.table
            @order.move(params[:target_table_id])
            render_invoice_form(former_table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'display_tax_colors'
            if session[:display_tax_colors]
              session[:display_tax_colors] = !session[:display_tax_colors] # toggle
            else
              session[:display_tax_colors] = true # set initial value
            end
            render_invoice_form(@order.table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'mass_assign_tax'
            tax = @current_vendor.taxes.find_by_id(params[:tax_id])
            @order.items.existing.each do |item|
              item.calculate_taxes([tax])
            end
            #@order.calculate_totals
            render_invoice_form(@order.table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'change_cost_center'
            @order.update_attribute(:cost_center_id, params[:cost_center_id])
            render :nothing => true and return # called from outside the static route() function, but nothing has to be rendered.
          #----------jsaction----------
          when 'assign_to_booking'
            @booking = @current_vendor.bookings.find_by_id(params[:booking_id])
            @order.update_attributes(:booking_id => @booking.id)
            @order.finish
            #@booking.calculate_totals
            @order.table.update_color
            if mobile?              
              # waiters on mobile devices never should be routed to the booking screen
              render_invoice_form(@order) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
            else
              render :js => "route('booking',#{@booking.id});" and return # called from outside the static route() function, but routing can be done via static JS.
            end
          #----------jsaction----------
          when 'pay_and_print'
            @order.pay
            @order.reload
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            render_invoice_form(@order.table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'pay_and_print_pending'
            @order.pay
            @order.reload
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
            render_invoice_form(@order.table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'pay_and_no_print'
            @order.pay
            @order.reload
            render_invoice_form(@order.table) and return # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
        end
      #===============CURRENTVIEW==================
      when 'table'
        case params['jsaction']
          #----------jsaction----------
          when 'send'
            get_order
            #@order.calculate_totals
            @order.regroup
            render :nothing => true and return if @order.hidden
            if @order.booking
              @order.finish
              @order.table.update_color
              render :js => "route('booking',#{@order.booking.id});" and return # order was entered into booking view. we can assume that no tickets have to be printed, so return here.
            end
            case params[:target]
              when 'tables' then
                @order.print(['tickets'])
                render :nothing => true and return # routing is done by the static route() function, so nothing to be done here.
              when 'invoice' then
                @order.print(['tickets'])
                render_invoice_form(@order.table) and return # the server has to render dynamically via .js.erb depending on the models.
              when 'table_no_invoice_print' then
                @order.pay
                @order.print(['tickets']) if @current_company.mode == 'local'
              when 'table_do_invoice_print' then
                @order.pay
                @order.print(['tickets','receipt'], @current_vendor.vendor_printers.existing.first) if @current_company.mode == 'local'
            end
            
            @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:model][:table_id])
            if @orders.empty?
              @order.table.update_attribute :user, nil
              render :js => "route('table',#{params[:model][:table_id]});" and return # the table view (variables, etc.) must be refreshed via an "AJAX-redirect".
            else
              render :js => "route('tables',#{params[:model][:table_id]});" and return # there is still one order open. it would confuse the user, when he would see the items of this order after he has finished, so we route to the tables view.
            end

          #----------jsaction----------
          when 'move'
            get_order
            @order.move(params[:target_table_id])
            @order.print(['tickets'])
            render :nothing => true and return # routing is done by static javascript to 'tables'
        end
        
      #===============CURRENTVIEW==================
      when 'room'
        case params['jsaction']
          #----------jsaction----------
          when 'send'
            get_booking
            #@booking.calculate_totals
            render :js => "route('rooms', '#{@booking.room_id}', 'update_bookings', #{@booking.to_json })" and return #this is an "AJAX redirect" since the rooms view has to be re-rendered AFTER all data have been processed. We cannot put this into the static JS route() function since that would render too quickly. A timeout would be possible, but oh, well.
          #----------jsaction----------
          when 'pay'
            get_booking
            #@booking.calculate_totals
            @booking.pay
            render :js => "route('rooms');" and return # see previous comment
          #----------jsaction----------
          when 'send_and_go_to_table'
            get_booking
            #@booking.calculate_totals
            render :js => "submit_json.model.booking_id = #{ @booking.id }" and return # the switch to the table happens in the JS route function from where this was called. the order view variables will not be fully  requested from the server, but submit_json.model.booking_id is the only variable we need for a successful order.
          #----------jsaction----------
          when 'send_and_redirect_to_invoice'
            get_booking
            #@booking.calculate_totals
            render :js => "window.location = '/bookings/#{ @booking.id }';" and return
          #----------jsaction----------
          when 'pay_and_redirect_to_invoice'
            get_booking
            #@booking.calculate_totals
            @booking.pay
            render :js => "window.location = '/bookings/#{ @booking.id }';" and return
        end
    end
  end

  def last_invoices
    @recent_unsettled_orders = @current_vendor.orders.existing.where(:settlement_id => nil, :finished => true, :user_id => @current_user.id).limit(5)
    if @current_user.role.permissions.include? 'finish_all_settlements'
      @permitted_users = @current_vendor.users
    elsif @current_user.role.permissions.include? 'finish_own_settlement'
      @permitted_users = [@current_user]
    else
      @permitted_users = []
    end
  end

  private
    
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
        @order.update_from_params(params, @current_user)
      else
        @order = Order.create_from_params(params, @current_vendor, @current_user)
        @order.set_nr
      end
      return @order
    end

    def get_booking
      @booking = Booking.accessible_by(@current_user).existing.find_by_id(params[:id]) if params[:id]
      if @booking
        @booking.update_from_params(params, @current_user)
      else
        @booking = Booking.create_from_params(params, @current_vendor, @current_user)
        @booking.set_nr
      end
      return @booking
    end
end
