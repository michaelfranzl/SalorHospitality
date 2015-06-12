# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class VendorsController < ApplicationController

  before_filter :check_permissions, :except => [:render_resources]
  after_filter :update_vendor_cache, :only => ['create','update']
  helper_method :permit

  def index
    @vendors = @current_user.vendors.existing
    if @vendors.count == 1
      @vendor = @vendors.first
      render :edit
    end
    return
  end
  
  # scope everything by this vendor, saves the vendor id in the session
  def show
    vendor = get_model
    redirect_to vendor_path and return unless vendor
    @current_vendor = vendor
    session[:vendor_id] = @current_user.default_vendor_id = params[:id] if vendor
    @current_user.save
    flash[:notice] = t('various.switched_to_vendor', :vendorname => vendor.name)
    redirect_to orders_path
  end

  # Edits the vendor
  def edit
    @vendor = get_model
    redirect_to vendor_path and return unless @vendor
    @current_vendor = @vendor
    session[:vendor_id] = params[:id] if @current_vendor
    @vendor ? render(:new) : redirect_to(vendors_path)
  end

  def update
    @vendor = get_model
    unless @vendor
      redirect_to vendors_path and return
    end
    
    permitted = params.require(:vendor).permit :name,
        :identifier,
        :email,
        :technician_email,
        :country,
        :time_offset,
        :ticket_space_top,
        :update_tables_interval,
        :update_item_lists_interval,
        :update_resources_interval,
        :receipt_header_blurb,
        :receipt_footer_blurb,
        :invoice_header_blurb,
        :invoice_footer_blurb,
        :enable_technician_emails,
        :ticket_wide_font,
        :ticket_tall_font,
        :ticket_item_separator,
        :ticket_display_time_order,
        :history_print,
        :remote_orders,
        :images_attributes => [
          :file_data,
          :image_type
        ],
        :vendor_printers_attributes => [
          :id,
          :name,
          :path,
          :print_button_filename,
          :copies,
          :codepage,
          :baudrate,
          :ticket_ad,
          :pulse_receipt,
          :pulse_tickets,
          :hidden,
          :cut_every_ticket,
          :one_ticket_per_piece
        ]
    
      unless @vendor.update_attributes permitted
      @vendor.images.reload
      render(:edit) and return 
    end
    #@vendor.images.update_all :company_id => @vendor.company_id
    @vendor.update_cache
    flash[:notice] = t('vendors.create.success')
    redirect_to edit_vendor_path(@vendor)
  end

  def new
    @vendor = Vendor.new
  end

  def create
    permitted = params.require(:vendor).permit :name,
        :identifier,
        :email,
        :technician_email,
        :country,
        :time_offset,
        :ticket_space_top,
        :update_tables_interval,
        :update_item_lists_interval,
        :update_resources_interval,
        :receipt_header_blurb,
        :receipt_footer_blurb,
        :invoice_header_blurb,
        :invoice_footer_blurb,
        :enable_technician_emails,
        :ticket_wide_font,
        :ticket_tall_font,
        :ticket_item_separator,
        :ticket_display_time_order,
        :history_print,
        :remote_orders,
        :images_attributes => [
          :file_data,
          :image_type
        ],
        :vendor_printers_attributes => [
          :id,
          :name,
          :path,
          :print_button_filename,
          :copies,
          :codepage,
          :baudrate,
          :ticket_ad,
          :pulse_receipt,
          :pulse_tickets,
          :hidden,
          :cut_every_ticket
        ]
    
    @vendor = Vendor.new permitted
    @vendor.company = @current_company
    if @vendor.save
      #@vendor.images.update_all :company_id => @vendor.company_id
      @vendor.update_cache
      @current_user.vendors << @vendor
      @current_user.save
      flash[:notice] = t('vendors.create.success')
      redirect_to vendors_path
    else
      render :new
    end
  end

  def destroy
    @vendor = get_model
    @vendor.hide
    #session[:vendor_id] = @current_company.vendors.existing.first.id
    redirect_to vendors_path
  end

  def render_resources
    resources = @current_vendor.resources_cache
    permissions = {
      :delete_items => permit("delete_items"),
      :decrement_items => permit("decrement_items"),
      :item_scribe => permit("item_scribe"),
      :see_item_notifications_user_preparation => permit("see_item_notifications_user_preparation"),
      :see_item_notifications_user_delivery => permit("see_item_notifications_user_delivery"),
      :see_item_notifications_vendor_preparation => permit("see_item_notifications_vendor_preparation"),
      :see_item_notifications_vendor_delivery => permit("see_item_notifications_vendor_delivery"),
      :see_item_notifications_static => permit("see_item_notifications_static"),
      :see_item_notifications_user_delivery => permit("see_item_notifications_user_delivery"),
      :manage_payment_methods => permit("manage_payment_methods"),
      :manage_customers => permit("manage_customers"),
      :manage_pages => permit("manage_pages"),
      :audio => (@current_user.audio unless @current_customer),
      :move_tables => permit("move_tables"),
      :add_option_to_sent_item => permit('add_option_to_sent_item'),
      :confirmation_user => (@current_user.confirmation_user unless @current_customer)
    }
    
    render :js => "
      permissions = #{ permissions.to_json };
      resources = #{ resources };
      timeout_update_tables = #{ @current_vendor.update_tables_interval }; 
      timeout_update_item_lists = #{ @current_vendor.update_item_lists_interval };
      timeout_update_resources = #{ @current_vendor.update_resources_interval };
      automatic_printing_interval = #{ @current_vendor.automatic_printing_interval * 1000 };
      user_login = '#{ @current_user.login if @current_user }';
      user_shift_ended = #{ @current_user.shift_ended };
      user_shift_duration = #{ @current_user.current_shift_duration };
      company_identifier = '#{ @current_company.identifier }';
    "
  end
  
  def report
    from = Time.parse(params[:from]).beginning_of_day
    to = Time.parse(params[:to]).end_of_day
    
    #------------------------ START WITH PARENT MODELS
    settlement_ids = @current_vendor.settlements.where(:created_at => from..to).collect { |s| s.id }
    
    order_ids = @current_vendor.orders.existing.where(:paid_at => from..to).collect { |o| o.id } unless settlement_ids.any? # If the user doesn't use the Settlement feature, user Orders gracefully instead.
    
    
    #------------------------ ITEMS
    if settlement_ids.any?
      items = Item.select("refund_sum, category_id, taxes").where(:settlement_id => settlement_ids, :hidden => nil)
    else
      items = Item.select("refund_sum, category_id, taxes").where(:order_id => order_ids, :hidden => nil)
    end
    items_json_string = items.collect{|i| "{\"r\":#{i.refund_sum ? i.refund_sum : 'null'},\"t\":#{i.taxes.to_json},\"y\":#{i.category_id}}" }.join(',')
    items_json_string.gsub! "\n", '\n'
    
    
    #------------------------ BOOKINGITEMS
    # Currently, the Settlements feature does not support Bookings, since it doesn't make much sense.
    booking_ids = @current_vendor.bookings.existing.where(:paid_at => from..to).collect { |o| o.id }
    booking_items = BookingItem.select("refund_sum, room_id, taxes, id").where(:booking_id => booking_ids, :hidden => nil)
    booking_items_json_string = booking_items.collect{|i| "{\"id\":#{i.id},\"r\":#{i.refund_sum.zero? ? 'null' : i.refund_sum},\"t\":#{i.taxes.to_json},\"m\":#{i.room_id}}" }.join(',')
    booking_items_json_string.gsub! "\n", '\n'
    
    #------------------------ PAYMENTMETHODITEMS

    if settlement_ids.any?
      payment_method_items = PaymentMethodItem.select("amount, refunded, payment_method_id, id").where(:settlement_id => settlement_ids, :hidden => nil)
    else
      payment_method_items = PaymentMethodItem.select("amount, refunded, payment_method_id, id").where(:booking_id => booking_ids, :hidden => nil)
    end
    
    payment_methods_json_string = payment_method_items.collect{|pmi| "{\"id\":#{pmi.id},\"r\":#{pmi.refunded ? 'true' : 'false'},\"a\":#{pmi.amount},\"pm_id\":#{pmi.payment_method_id}}" }.join(',')
    payment_methods_json_string.gsub! "\n", '\n'
    payment_methods_json_string = ''
    
    #------------------------ OUTPUT
    render :json => "{\"items\":[#{items_json_string}], \"booking_items\":[#{booking_items_json_string}],\"payment_method_items\":[#{payment_methods_json_string}]}"
  end
  
  def identify_printers
    Escper::Printer.new(@current_company.mode).identify
    render :nothing => true
  end
  
  def test_printers
    Escper::Printer.new(@current_company.mode, @current_vendor.vendor_printers.existing, File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, @current_vendor.hash_id)).identify(params[:chartest])
    render :nothing => true
  end
  
  def online_status
    render :text => 'online'
  end
  
  def generic_print
    @current_vendor.generic_print(params[:text])
    render :nothing => true
  end
end
