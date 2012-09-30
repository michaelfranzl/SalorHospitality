# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'net/http'
class ApplicationController < ActionController::Base
  helper :all
  before_filter :fetch_logged_in_user, :set_locale

  helper_method :logged_in?, :mobile?, :mobile_special?, :workstation?
  
  def route
    #puts "XXXXXXXXXXXXX #{params[:currentview]}"
    #puts "XXXXXXXXXXXXX #{params[:jsaction]}"
    case params[:currentview]
      #===============CURRENTVIEW==================
      # this action is for simple writing of any model to the server and getting a Model object back. 
      when 'push'
        if params[:relation]
          @model = @current_vendor.send(params[:relation]).existing.find_by_id(params[:id])
          @model.update_attributes(params[:model])
          render :json => @model
        end
      #===============CURRENTVIEW==================
      when 'invoice_paper', 'refund'
        get_order
        case params['jsaction']
          #----------jsaction----------
          when 'just_print'
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
          #----------jsaction----------
          when 'mark_print_pending'
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
        end
        render :nothing => true
      #===============CURRENTVIEW==================
      when 'invoice'
        get_order
        case params['jsaction']
          #----------jsaction----------
          when 'move'
            former_table = @order.table
            @order.move(params[:target_table_id])
            render_invoice_form(former_table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'display_tax_colors'
            if session[:display_tax_colors]
              session[:display_tax_colors] = !session[:display_tax_colors] # toggle
            else
              session[:display_tax_colors] = true # set initial value
            end
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'mass_assign_tax'
            tax = @current_vendor.taxes.find_by_id(params[:tax_id])
            @order.items.existing.each do |item|
              item.calculate_taxes([tax])
            end
            #@order.calculate_totals
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'change_cost_center'
            @order.update_attribute(:cost_center_id, params[:cost_center_id])
            render :nothing => true # called from outside the static route() function, but nothing has to be rendered.
          #----------jsaction----------
          when 'assign_to_booking'
            @booking = @current_vendor.bookings.find_by_id(params[:booking_id])
            @order.update_attributes(:booking_id => @booking.id)
            @order.finish
            @booking.calculate_totals
            @order.table.update_color
            if mobile?              
              # waiters on mobile devices never should be routed to the booking screen
              render_invoice_form(@order) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
            else
              render :js => "route('booking',#{@booking.id});" # called from outside the static route() function, but routing can be done via static JS.
            end
          #----------jsaction----------
          when 'pay_and_print'
            @order.pay
            @order.reload
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'pay_and_print_pending'
            @order.pay
            @order.reload
            @order.update_attribute :print_pending, true
            @current_vendor.update_attribute :print_data_available, true
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'pay_and_no_print'
            @order.pay
            @order.reload
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
        end
      #===============CURRENTVIEW==================
      when 'table'
        get_order
        case params['jsaction']
          #----------jsaction----------
          when 'send'
            #render :nothing => true and return if @order.hidden
            @order.table.update_color
            if @order.booking
              @order.finish
              @order.booking.calculate_totals
              render :js => "route('booking',#{@order.booking.id});" # order was entered into booking view. we can assume that no tickets have to be printed, so return here.
            elsif not @order.hidden
              case params[:target]
                when 'tables'
                  @order.print(['tickets'])
                  render :nothing => true # routing is done by the static route() function, so nothing to be done here.
                when 'invoice'
                  @order.print(['tickets'])
                  render_invoice_form(@order.table) # the server has to render dynamically via .js.erb depending on the models.
                when 'table_no_invoice_print'
                  @order.pay
                  @order.print(['tickets']) if @current_company.mode == 'local'
                  
                  @table = @order.table
                  @order = nil
                  render 'orders/render_order_form'
                when 'table_do_invoice_print'
                  @order.pay
                  @order.print(['tickets','receipt'], @current_vendor.vendor_printers.existing.first) if @current_company.mode == 'local'
                  
                  @table = @order.table
                  @order = nil
                  render 'orders/render_order_form'
              end
            else
              render :nothing => true
            end
          #----------jsaction----------
          when 'move'
            @order.print(['tickets'])
            @order.move(params[:target_table_id])
            render :nothing => true # routing is done by static javascript to 'tables'
        end
      #===============CURRENTVIEW==================
      when 'room'
        get_booking
        case params['jsaction']
          #----------jsaction----------
          when 'send'
            render :js => "route('rooms', '#{@booking.room_id}', 'update_bookings', #{@booking.to_json })" #this is an "AJAX redirect" since the rooms view has to be re-rendered AFTER all data have been processed. We cannot put this into the static JS route() function since that would render too quickly. A timeout would be possible, but oh, well.
          #----------jsaction----------
          when 'pay'
            @booking.pay
            render :js => "route('rooms');" # see previous comment
          #----------jsaction----------
          when 'send_and_go_to_table'
            render :js => "submit_json.model.booking_id = #{ @booking.id }" # the switch to the table happens in the JS route function from where this was called. the order view variables will not be fully  requested from the server, but submit_json.model.booking_id is the only variable we need for a successful order.
          #----------jsaction----------
          when 'send_and_redirect_to_invoice'
            render :js => "window.location = '/bookings/#{ @booking.id }';"
          #----------jsaction----------
          when 'pay_and_redirect_to_invoice'
            @booking.pay
            render :js => "window.location = '/bookings/#{ @booking.id }';"
        end
    end
    if @current_user.role.permissions.include?('see_debug')
      @order.check if @order
      @booking.check if @booking
    end
    return
  end

  private
  
    def get_model(model_id=nil, model=nil)
      id = model_id ? model_id : params[:id]
      if id
        model ||= controller_name.classify.constantize
        object = model.accessible_by(@current_user).existing.find_by_id(id)
        if object.nil?
          flash[:error] = t('not_found')
        end
      end
      return object
    end
  
    def get_order
      if params[:id]
        @order = get_model(params[:id], Order)
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

    def assign_from_to(p)
      begin
        f = Date.civil( p[:from][:year ].to_i,
                        p[:from][:month].to_i,
                        p[:from][:day  ].to_i) if p[:from]
        t = Date.civil( p[:to  ][:year ].to_i,
                        p[:to  ][:month].to_i,
                        p[:to  ][:day  ].to_i) + 1.day if p[:to]
      rescue
        flash[:error] = t(:invalid_date)
        f = Time.now.beginning_of_day
        t = Time.now.end_of_day
      end
      return f, t
    end

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.find_by_id session[:user_id] if session[:user_id]
      @current_company = @current_user.company if @current_user
      @current_vendor = Vendor.existing.find_by_id session[:vendor_id] if session[:vendor_id]
      session[:vendor_id] = nil and session[:company_id] = nil unless @current_vendor

      # we need these for the history observer because we don't have control at the time
      # the activerecord callbacks run, and anyway controller instance variables wouldn't
      # be in scope...
      $User = @current_user
      $Request = request
      $Params = params

      redirect_to new_session_path unless @current_user and @current_vendor
    end

    # the invoice view can contain 1 or 2 non-finished orders. if it contains 2 orders, and 1 is finished, then stay on the invoice view and just display the remaining order, otherwise go to the main (tables) view.
    def render_invoice_form(table)
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => table.id)
      @cost_centers = @current_vendor.cost_centers.existing.active
      @taxes = @current_vendor.taxes.existing
      @tables = @current_vendor.tables.existing
      @bookings = @current_vendor.bookings.existing.where("`paid` = FALSE AND `from_date` < ? AND `to_date` > ?", Time.now, Time.now)
      if @orders.empty?
        table.update_attribute :user, nil if @orders.empty?
        render :js => "route('tables');" and return
      else
        render 'orders/render_invoice_form'
      end
    end

    def set_locale
      I18n.locale = @current_user ? @current_user.language : 'en'
    end

    def update_vendor_cache
      @current_vendor.update_cache
    end

    def check_permissions
      redirect_to '/' and return unless @current_user.role.permissions.include? "manage_#{ controller_name }"
    end

    def workstation?
      request.user_agent.nil? or request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh') or request.user_agent.include?('Chromium') or request.user_agent.include?('Chrome') or request.user_agent.include?('iPad')
    end

    def mobile?
      not workstation?
    end

    def mobile_special?
      request.user_agent.include?('iPad')
    end

    def neighbour_models(model_name, model_object)
      models = @current_vendor.send(model_name).existing.where(:finished => true)
      idx = models.index(model_object)
      previous_model = models[idx-1] if idx
      previous_model = model_object if previous_model.nil?
      next_model = models[idx+1] if idx
      next_model = model_object if next_model.nil?
      return previous_model, next_model
    end
    
end
