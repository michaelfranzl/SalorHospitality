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
  before_filter :fetch_logged_in_user, :set_locale, :set_tailor, :set_up, :autologout_customers

  helper_method :mobile?, :mobile_special?, :workstation?, :permit

  unless SalorHospitality::Application.config.consider_all_requests_local
    rescue_from(Exception, :with => :render_error)
  end
  
  def create_history_for_route
    return if SalorHospitality::Application::CONFIGURATION[:history] == false
    h = History.new
    if params.has_key?('model')
      h.model_type = 'Table'
      h.model_id = params[:model][:table_id]
      if params['jsaction'] == 'send'
        if params['model'].has_key?('user_id')
          h.changes_made = 'send_change_user'
        else
          h.changes_made = "send_goto_#{ params['target'] }_from_#{ params['currentview'] }"
        end
      elsif params['jsaction'] == 'move'
        h.changes_made = "move_from_#{ params[:model][:table_id] }_to_#{ params['target_table_id'] }"
      end
    end
    h.action_taken = 'route'
    h.save
  end
  
  def route
    create_history_for_route
    case params[:currentview]
      # this action is for simple writing of any model to the server and getting a Model object back. 
      when 'push'
        if params[:relation]
          @model = @current_vendor.send(params[:relation]).existing.find_by_id(params[:id])
          @model.update_attributes(params[:model])
          render :json => @model
        end
      
      when 'invoice_paper', 'order_summary'
        case params['jsaction']
          #----------jsaction----------
          when 'just_print'
            @order = get_order
            @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer]), {:with_customer_lines => true}) if params[:printer]
        end
        render :nothing => true
      
      when 'invoice'
        case params['jsaction']
          #----------jsaction----------
          when 'move'
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            former_table = @order.table
            @order.move(params[:target_table_id])
            render_invoice_form(former_table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'display_tax_colors'
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            if session[:display_tax_colors]
              session[:display_tax_colors] = !session[:display_tax_colors] # toggle
            else
              session[:display_tax_colors] = true # set initial value
            end
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'mass_assign_tax'
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            tax = @current_vendor.taxes.find_by_id(params[:tax_id])
            @order.items.existing.each do |item|
              item.calculate_taxes([tax])
            end
            @order.calculate_totals
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
          #----------jsaction----------
          when 'change_cost_center'
            cid = params[:cost_center_id]
            params[:payment_method_items] = nil # we want to create them when user is done with the invoice form.
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            @order.update_attribute :cost_center_id, cid 
            @order.tax_items.update_all :cost_center_id => cid
            @order.payment_method_items.update_all :cost_center_id => cid
            @order.items.update_all :cost_center_id => cid
            render_invoice_form(@order.table)
          #----------jsaction----------
          when 'assign_to_booking'
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
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
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            if params[:interim] == 'true'
              @order.print(['interim_receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
              render_invoice_form(@order.table)
            else
              #Item.split_items(params[:split_items_hash], @order) if params[:split_items_hash]
              @order.pay
              @order.reload
              @order.print(['receipt'], @current_vendor.vendor_printers.find_by_id(params[:printer])) if params[:printer]
              render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
            end
          #----------jsaction----------
          when 'pay_and_no_print'
            @order = get_order
            if @order.finished == true
              render :js => "order_already_finished();"
              return
            end
            #Item.split_items(params[:split_items_hash], @order) if params[:split_items_hash]
            @order.pay
            @order.reload
            render_invoice_form(@order.table) # called from outside the static route() function, so the server has to render dynamically via .js.erb depending on the models.
        end
      
      when 'table'
        @order = get_order
        if @order.finished == true
          render :js => "order_already_finished();"
          return
        end
        case params['jsaction']
          #----------jsaction----------
          when 'send'
            if @order.booking
              @order.finish(@current_user)
              @order.booking.calculate_totals
              render :js => "setTimeout(function(){route('booking',#{@order.booking.id})}, 200);" # order was entered into booking view. we can assume that no tickets have to be printed, so return here.
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
                  
                when 'tables_no_invoice_print'
                  @order.pay(@current_user)
                  @order.print(['tickets'])
                  @table = @order.table
                  @order = nil
                  render :nothing => true
                when 'tables_do_invoice_print'
                  @order.pay(@current_user)
                  @order.print(['tickets','receipt'], @current_vendor.vendor_printers.existing.first)
                  @table = @order.table
                  @order = nil
                  render :nothing => true

                when 'table_interim_receipt_print'
                  @order.print(['interim_receipt'], @current_vendor.vendor_printers.existing.first)
                  render :nothing => true
                when 'table_request_send'
                  @table = @order.table
                  if @current_customer.default_table_id
                    render 'orders/render_order_form'
                  else
                    render :js => "logout({notice:'Thank you. Your order is being processed.'});"
                  end
                  
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
              render 'orders/render_order_form'
              #render :nothing => true
            end
          #----------jsaction----------
          when 'move'
            @order.print(['tickets'])
            @order.move(params[:target_table_id])
            render :nothing => true # routing is done by static javascript to 'tables'

        end
      
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
    return
  end

  private
  
    def set_up
      SalorHospitality.requestcount += 1
      
      if defined?(ShSaas) == 'constant'
        @sessionpath = sh_saas.session_path
      else
        @sessionpath = session_path
      end
      
      if params[:notice] and params[:notice].empty? == false
        flash[:notice] = params[:notice]
      end
      
      if params[:error] and params[:error].empty? == false
        flash[:error] = params[:error]
      end
    end
    
    def autologout_customers
      if SalorHospitality.requestcount % 10 == 0
        # every 10 requests
        @from = 100.years.ago
        @to = 20.minutes.ago
        Customer.existing.where(:logged_in => true, :last_login_at => @from..@to).each do |c|
          logger.info "AUTO LOGGING OUT CUSTOMER #{ c.inspect }"
          c.logged_in = false
          c.table = nil
          c.save
        end
      end
    end
  
    def set_tailor
      return unless @current_vendor and SalorHospitality::Application::CONFIGURATION[:tailor] and SalorHospitality::Application::CONFIGURATION[:tailor] == true
      
      t = SalorHospitality.tailor
      # check if stream is open. if not, create a new one
      if t
        #logger.info "[TAILOR] Checking if socket #{ t.inspect } is healthy"
        begin
          t.puts "PING|#{ @current_vendor.hash_id }|#{ Process.pid }"
        rescue Errno::EPIPE
          logger.info "[TAILOR] Error: Broken pipe for #{ t.inspect } #{ t }"
          SalorHospitality.old_tailors << t
          t = nil
        rescue Errno::ECONNRESET
          logger.info "[TAILOR] Error: Connection reset by peer for #{ t.inspect } #{ t }"
          SalorHospitality.old_tailors << t
          t = nil
        rescue Exception => e
          logger.info "[TAILOR] Other Error: #{ e.inspect } for #{ t.inspect } #{ t }"
          SalorHospitality.old_tailors << t
          t = nil
        end
      end
      
      if t.nil?
        begin
          t = TCPSocket.new 'localhost', 2001
          logger.info "[TAILOR] Info: New TCPSocket #{ t.inspect } #{ t } created"
        rescue Errno::ECONNREFUSED
          t = nil
          logger.info "[TAILOR] Warning: Connection refused. No tailor.rb server running?"
        end
        SalorHospitality.tailor = t
      end

    end
  
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
  
    
    # convenience function for creating or updating an order
    def get_order
      
      if @current_customer
        params[:model][:table_id] = @current_customer.table.id # security measure for js manipulation
      end
      
      if params[:id]
        # get a specific order
        order = get_model(params[:id], Order)
      elsif params[:model] and params[:model][:table_id]
        # Reuse the order on table if possible. Happens when 2 devices are entering a table without order at the same time, and one of the users submits first.
        order = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:model][:table_id]).last
      end

      if order and order.finished == true
        # do not update or create the order, simply return it
        return order
      elsif order
        order.update_from_params(params, @current_user, @current_customer)
      else
        order = Order.create_from_params(params, @current_vendor, @current_user, @current_customer)
      end
      return order
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
      tz = sprintf("%+i", @current_vendor.total_utc_offset_hours)
      if p[:from]
        fy = p[:from][:year ].to_i
        fm = p[:from][:month].to_i
        fd = p[:from][:day  ].to_i
        begin
          f = DateTime.new(fy,fm,fd,0,0,0,tz)
        rescue
          flash[:error] = t(:invalid_date)
        end
      end
      if p[:to]
        ty = p[:to][:year ].to_i
        tm = p[:to][:month].to_i
        td = p[:to][:day  ].to_i
        begin
          t = DateTime.new(ty,tm,td,23,59,59,tz)
        rescue
          flash[:error] = t(:invalid_date)
        end
      end
      
      # the database stores UTC times. If we use the time functios of ruby below, the application time zone will already be attached, so it works out of the box.
      f ||= DateTime.now.beginning_of_day - 1.week
      t ||= DateTime.now
      
      return f, t
    end

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.existing.active.find_by_id session[:user_id] if session[:user_id]
      @current_customer = Customer.find_by_id_hash session[:customer_id_hash] if session[:customer_id_hash]
      
      @current_company = Company.existing.find_by_id session[:company_id] if session[:company_id]
      @current_vendor = Vendor.existing.find_by_id session[:vendor_id] if session[:vendor_id]

      unless @current_vendor
        session[:vendor_id] = nil and session[:company_id] = nil
        #flash[:notice] = "Invalid Vendor"
        redirect_to new_session_path and return
      end

      # we need these global variables for the history observer model
      $User = @current_user
      $Vendor = @current_vendor
      $Company = @current_company
      $Request = request
      $Params = params
      
      if @current_user and not (@current_user.advertising_url.nil? or @current_user.advertising_url.empty?)
        @advertising_url = @current_user.advertising_url
      end
      
      if @current_vendor and @current_vendor.branding != {}
        @branding_codename = @current_vendor.branding[:codename]
        @branding_title = @current_vendor.branding[:title]
      else
        @branding_codename = 'salorhospitality'
        @branding_title = 'SALOR Hospitality'
      end

    
      if @current_user.nil? and @current_customer.nil?
        session[:user_id] = nil
        if request.xhr?
          if defined?(ShSaas) == 'constant'
            render :js => "window.location = '/signin';" and return
          else
            render :js => "window.location = '#{new_session_path}';" and return
          end
        else
          if defined?(ShSaas) == 'constant'
            redirect_to "/signin" and return
          else
            redirect_to new_session_path and return
          end
        end
      end
      
        
      if @current_customer and @current_customer.logged_in != true
        session[:customer_id] = nil
        flash[:error] = "Automatically logged out"
        if request.xhr?
          if defined?(ShSaas) == 'constant'
            render :js => "window.location = '/login';" and return
          else
            render :js => "window.location = '#{new_customer_session_path}';" and return
          end
        else
          if defined?(ShSaas) == 'constant'
            redirect_to '/login' and return
          else
            redirect_to new_customer_session_path and return
          end
        end
      end
    end

    # the invoice view can contain 1 or 2 non-finished orders. if it contains 2 orders, and 1 is finished, then stay on the invoice view and just display the remaining order, otherwise go to the main (tables) view.
    def render_invoice_form(table)
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => table.id)
      @cost_centers = @current_vendor.cost_centers.existing
      @taxes = @current_vendor.taxes.existing
      @tables = @current_user.tables.existing.where(:vendor_id => @current_vendor.id)
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
        unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
          browser_language = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
          browser_language = 'gn' if browser_language == 'de'
        end
        if browser_language.nil? or browser_language.empty? or not I18n.available_locales.include?(browser_language.to_sym)
          I18n.locale = @locale = session[:locale] = 'en'
        else
          I18n.locale = @locale = session[:locale] = browser_language
        end
      end
      @region = @current_vendor.region if @current_vendor
    end

    def update_vendor_cache
      @current_vendor.update_cache
    end

    def check_permissions
      redirect_to '/' and return unless permit("manage_#{ controller_name }")
    end

    def workstation?
      autodetect =
          request.user_agent.nil? ||
          request.user_agent.include?('Firefox') ||
          request.user_agent.include?('MSIE') ||
          request.user_agent.include?('Macintosh') ||
          request.user_agent.include?('Chromium') ||
          request.user_agent.include?('Chrome') ||
          request.user_agent.include?('Qt/')
      
      if @current_user.nil? or @current_user.layout == 'auto'
        return autodetect
      elsif @current_user.layout == 'workstation'
        return true
      elsif @current_user.layout == 'mobile'
        return false
      end
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
      request.user_agent and request.user_agent.include?('iPad')
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
    
  protected

  def render_error(exception)
    logger.info exception.backtrace.join("\n")
    raise exception if request.xhr?
    @exception = exception
    if SalorHospitality::Application::CONFIGURATION[:exception_notification] == true
      if notifier = Rails.application.config.middleware.detect { |x| x.klass == ExceptionNotifier }
        env['exception_notifier.options'] = notifier.args.first || {}                   
        ExceptionNotifier::Notifier.exception_notification(env, exception).deliver
        env['exception_notifier.delivered'] = true
      end
    end
    render :template => '/errors/error', :layout => 'exception'
  end
    
end
