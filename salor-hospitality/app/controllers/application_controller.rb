# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class ApplicationController < ActionController::Base
  # protect_from_forgery
  #helper :all
  before_filter :fetch_logged_in_user, :set_locale

  helper_method :mobile?, :mobile_special?, :workstation?, :permit
  
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
        case params['jsaction']
          #----------jsaction----------
          when 'just_print'
            get_order
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer]), {:with_customer_lines => true}) if params[:printer]
          when 'do_refund'
            item = get_model(params[:id], Item)
            item.refund(@current_user, params[:payment_method_id])
            @order = item.order
            render 'items/edit' and return # this renders a .js.erb tempate, which in turn renders partial => 'orders/refund_form'
        end
        render :nothing => true
      #===============CURRENTVIEW==================
      when 'invoice'
        case params['jsaction']
          #----------jsaction----------
          when 'move'
            get_order
            former_table = @order.table
            @order.move(params[:target_table_id])
            render_invoice_form(former_table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'display_tax_colors'
            get_order
            if session[:display_tax_colors]
              session[:display_tax_colors] = !session[:display_tax_colors] # toggle
            else
              session[:display_tax_colors] = true # set initial value
            end
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'mass_assign_tax'
            get_order
            tax = @current_vendor.taxes.find_by_id(params[:tax_id])
            @order.items.existing.each do |item|
              item.calculate_taxes([tax])
            end
            #@order.calculate_totals
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'change_cost_center'
            cid = params[:cost_center_id]
            params[:payment_method_items] = nil # we want to create them when user is done with the invoice form.
            get_order
            @order.update_attribute :cost_center_id, cid 
            @order.tax_items.update_all :cost_center_id => cid
            @order.payment_method_items.update_all :cost_center_id => cid
            @order.items.update_all :cost_center_id => cid
            render_invoice_form(@order.table)
          #----------jsaction----------
          when 'assign_to_booking'
            get_order
            @booking = @current_vendor.bookings.find_by_id(params[:booking_id])
            @order.update_attributes(:booking_id => @booking.id)
            @order.finish(@current_user)
            @booking.calculate_totals
            if mobile?              
              # waiters on mobile devices never should be routed to the booking screen
              render_invoice_form(@order) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
            else
              render :js => "route('booking',#{@booking.id});" # called from outside the static route() function, but routing can be done via static JS.
            end
          #----------jsaction----------
          when 'pay_and_print'
            get_order
            Item.split_items(params[:split_items_hash], @order) if params[:split_items_hash]
            @order.pay
            @order.reload
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'pay_and_no_print'
            get_order
            Item.split_items(params[:split_items_hash], @order) if params[:split_items_hash]
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
            if @order.booking
              @order.finish(@current_user)
              @order.booking.calculate_totals
              render :js => "route('booking',#{@order.booking.id});" # order was entered into booking view. we can assume that no tickets have to be printed, so return here.
            elsif not @order.hidden
              case params[:target]
                when 'tables'
                  @order.print(['tickets'])
                  render :nothing => true # routing is done by the static route() function, so nothing to be done here.
                when 'invoice'
                  @order.print(['tickets'])
                  @order.user = @current_user unless workstation?
                  @order.save
                  @order.table.update_color
                  render_invoice_form(@order.table) # the server has to render dynamically via .js.erb depending on the models.
                when 'table_no_invoice_print'
                  @order.pay(@current_user)
                  @order.print(['tickets'])
                  @table = @order.table
                  @order = nil
                  render 'orders/render_order_form'
                when 'table_do_invoice_print'
                  @order.pay(@current_user)
                  @order.print(['tickets','receipt'], @current_vendor.vendor_printers.existing.first)
                  @table = @order.table
                  @order = nil
                  render 'orders/render_order_form'
                when 'table_request_send'
                  @table = @order.table
                  render 'orders/render_order_form'
                when 'table_request_finish'
                  @table = @order.table
                  @table.set_request_finish
                  render 'orders/render_order_form'
                when 'table_request_waiter'
                  @table = @order.table
                  @table.set_request_waiter
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
            render :js => "route('rooms', '#{@booking.room_id}', 'update_bookings', #{@booking.to_json })" #this is an "AJAX redirect" since the rooms view has to be re-rendered AFTER all data have been processed. We cannot put this into the static JS route() function since that would render too quickly.
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
    if permit('see_debug')
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
        if @current_vendor.enable_technician_emails == true and @current_vendor.technician_email
          UserMailer.technician_message(@current_vendor, "params[:model][:table_id] was not set").deliver
          Email.create :receipient => @current_vendor.technician_email, :subject => "params[:model][:table_id] was not set", :body => '', :vendor_id => @current_vendor.id, :company_id => @current_company.company_id, :technician => true
        else
          ActiveRecord::Base.logger.info "[TECHNICIAN] params[:model][:table_id] was not set"
        end
        
      end
      if @order
        params[:model][:table_id] = @order.table_id if params[:model] # under high load, table_id may be wrong. We simply do not allow to change the table_id of the order.
        @order.update_from_params(params, @current_user, @current_customer)
      else
        @order = Order.create_from_params(params, @current_vendor, @current_user, @current_customer)
      end
      return @order
    end

    def get_booking
      @booking = Booking.accessible_by(@current_user).existing.find_by_id(params[:id]) if params[:id]
      if @booking
        @booking.update_from_params(params, @current_user)
      else
        @booking = Booking.create_from_params(params, @current_vendor, @current_user)
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
                        p[:to  ][:day  ].to_i) if p[:to]
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
      @current_user = User.existing.active.find_by_id session[:user_id] if session[:user_id]
      @current_customer = Customer.find_by_id session[:customer_id] if session[:customer_id]
      
      @current_company = Company.existing.find_by_id session[:company_id] if session[:company_id]
      @current_vendor = Vendor.existing.find_by_id session[:vendor_id] if session[:vendor_id]

      session[:vendor_id] = nil and session[:company_id] = nil unless @current_vendor

      # we need these for the history observer because we don't have control at the time
      # the activerecord callbacks run, and anyway controller instance variables wouldn't
      # be in scope...
      $User = @current_user
      $Request = request
      $Params = params

      unless (@current_user or @current_customer) and @current_vendor
        if defined?(ShSaas) == 'constant'
          redirect_to sh_saas.new_session_path
        else
          redirect_to new_session_path
        end
      end
    end

    # the invoice view can contain 1 or 2 non-finished orders. if it contains 2 orders, and 1 is finished, then stay on the invoice view and just display the remaining order, otherwise go to the main (tables) view.
    def render_invoice_form(table)
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => table.id)
      @cost_centers = @current_vendor.cost_centers.existing
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
      if params[:l] and I18n.available_locales.include? params[:l].to_sym
        I18n.locale = @locale = session[:locale] = params[:l]
      elsif session[:locale]
        I18n.locale = @locale = session[:locale]
      elsif @current_user
        I18n.locale = @locale = session[:locale] = @current_user.language
      elsif @current_customer
        I18n.locale = @locale = session[:locale] = @current_customer.language
      else
        browser_language = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
        browser_language = 'gn' if browser_language == 'de'
        if browser_language.nil? or browser_language.empty? or not I18n.available_locales.include?(browser_language.to_sym)
          I18n.locale = @locale = session[:locale] = 'en'
        else
          I18n.locale = @locale = session[:locale] = browser_language
        end
      end
      
      @region = SalorHospitality::Application::COUNTRIES_REGIONS[@current_vendor.country] if @current_vendor
    end

    def update_vendor_cache
      @current_vendor.update_cache
    end

    def check_permissions
      redirect_to '/' and return unless permit("manage_#{ controller_name }")
    end

    def workstation?
      request.user_agent.nil? or request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh') or request.user_agent.include?('Chromium') or request.user_agent.include?('Chrome') or request.user_agent.include?('Qt/')
    end
    
    def permit(p)
      if @current_user
        return @current_user.role.permissions.include?(p)
      elsif @current_customer
        return false #@current_customer.role.permissions.include?(p)
      end
    end

    def mobile?
      not workstation?
    end

    def mobile_special?
      request.user_agent.include?('iPad')
    end

    def neighbour_models(model_name, model_object)
      first_model = @current_vendor.send(model_name).existing.where(:finished => true).first
      last_model = @current_vendor.send(model_name).existing.where(:finished => true).last
      search_id = model_object.id
      previous_model = model_object == first_model ? model_object : nil
      while previous_model.nil?
        search_id -= 1
        model = @current_vendor.send(model_name).existing.find_by_id(search_id)
        previous_model = model if model and model.finished
      end
      
      search_id = model_object.id
      next_model = model_object == last_model ? model_object : nil
      while next_model.nil?
        search_id += 1
        model = @current_vendor.send(model_name).existing.find_by_id(search_id)
        next_model = model if model and model.finished
      end
      
      return previous_model, next_model
    end
    
end
