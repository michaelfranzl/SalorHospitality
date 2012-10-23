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

  def index
    respond_to do |wants|
      wants.json {
        status = @current_vendor.print_data_available == true ? 'true' : 'false'
        render :json => "{\"print_data_available\":#{status}}"
        return
      }
      wants.html {
        @vendors = @current_company.vendors.existing
        if @vendors.count == 1
          @vendor = @vendors.first
          render :edit
        end
        return
      }
    end
  end
  
  def print
    # Return a file that contains all not yet printed Items and all Orders that are marked for printing
    orders = @current_vendor.orders.existing.where(:print_pending => true)
    tickets = orders.collect{ |o| o.escpos_tickets(nil) }.join
    invoices = orders.collect{ |o| o.escpos_receipt }.join
    orders.update_all :print_pending => false
    @current_vendor.update_attribute :print_data_available, false
    send_data tickets + invoices
  end

  def show
    vendor = get_model
    redirect_to vendor_path and return unless vendor
    @current_vendor = vendor
    session[:vendor_id] = params[:id] if @current_vendor
    redirect_to vendors_path
  end

  # Edits the vendor
  def edit
    @vendor = get_model
    redirect_to vendor_path and return unless @vendor
    @current_vendor = vendor
    session[:vendor_id] = params[:id] if @current_vendor
    @vendor ? render(:new) : redirect_to(vendors_path)
  end

  def update
    @vendor = get_model
    redirect_to vendors_path and return unless @vendor
    unless @vendor.update_attributes params[:vendor]
      @vendor.images.reload
      render(:edit) and return 
    end
    flash[:notice] = t('vendors.create.success')
    redirect_to vendors_path
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new params[:vendor]
    @vendor.company = @current_company
    if @vendor.save
      flash[:notice] = t('vendors.create.success')
      redirect_to vendors_path
    else
      render :new
    end
  end

  def destroy
    @vendor = get_model
    @vendor.hide
    session[:vendor_id] = @current_company.vendors.existing.first.id
    redirect_to vendors_path
  end

  def render_resources
    resources = @current_vendor.resources_cache
    permissions = {
      :delete_items => @current_user.role.permissions.include?("delete_items"),
      :decrement_items => @current_user.role.permissions.include?("decrement_items"),
      :item_scribe => @current_user.role.permissions.include?("item_scribe"),
      :see_item_notifications_user_preparation => @current_user.role.permissions.include?("see_item_notifications_user_preparation"),
      :see_item_notifications_user_delivery => @current_user.role.permissions.include?("see_item_notifications_user_delivery"),
      :see_item_notifications_vendor_preparation => @current_user.role.permissions.include?("see_item_notifications_vendor_preparation"),
      :see_item_notifications_vendor_delivery => @current_user.role.permissions.include?("see_item_notifications_vendor_delivery"),
      :see_item_notifications_static => @current_user.role.permissions.include?("see_item_notifications_static"),
      :see_item_notifications_user_delivery => @current_user.role.permissions.include?("see_item_notifications_user_delivery"),
      :manage_payment_methods => @current_user.role.permissions.include?("manage_payment_methods"),
      :manage_customers => @current_user.role.permissions.include?("manage_customers"),
      :audio => @current_user.audio
    }
    render :js => "permissions = #{ permissions.to_json }; resources = #{ resources };"
  end
  
  def report
    from = Time.parse(params[:from]).beginning_of_day
    to = Time.parse(params[:to]).end_of_day
    #sql = ActiveRecord::Base.connection
    #x = %q[SELECT CONCAT("[", GROUP_CONCAT(  CONCAT('{"r":', IF(refund_sum, refund_sum,'null'), ',"y":', category_id, ',"t":"', REPLACE(taxes,"\n","\\\n"), '"'),   '}'), ']') FROM items]
    #x += ";"
    #result = sql.execute x
    #render :json => result.to_a[0][0]
    #settlement_ids = @current_vendor.settlements.where(:created_at => from..to).collect { |s| s.id }
    
    #------------------------ ITEMS
    settlement_ids = @current_vendor.settlements.existing.where(:created_at => from..to).collect { |s| s.id }
    if settlement_ids.any?
      items = Item.select("refund_sum, category_id, taxes").where(:settlement_id => settlement_ids, :hidden => nil)
    else
      # User is not using the Settlement feature. Load orders strictly by date instead. This has the disadvantage that orders, which were taken after midnight, but by common sense belong to the previous workday, will count for the next day.
      order_ids = @current_vendor.orders.existing.where(:paid_at => from..to).collect { |o| o.id }
      items = Item.select("refund_sum, category_id, taxes").where(:order_id => order_ids, :hidden => nil)
    end
    items_json_string = items.collect{|i| "{\"r\":#{i.refund_sum ? i.refund_sum : 'null'},\"t\":#{i.taxes.to_json},\"y\":#{i.category_id}}" }.join(',')
    items_json_string.gsub! "\n", '\n'
    
    
    #------------------------ BOOKINGITEMS
    booking_ids = @current_vendor.bookings.existing.where(:paid_at => from..to).collect { |o| o.id }
    booking_items = BookingItem.select("refund_sum, room_id, taxes, id").where(:booking_id => booking_ids, :hidden => nil)
    booking_items_json_string = booking_items.collect{|i| "{\"id\":#{i.id},\"r\":#{i.refund_sum ? i.refund_sum : 'null'},\"t\":#{i.taxes.to_json},\"m\":#{i.room_id}}" }.join(',')
    booking_items_json_string.gsub! "\n", '\n'
    
    #------------------------ PAYMENTMETHODITEMS
    
    booking_items = BookingItem.select("refund_sum, room_id, taxes, id").where(:booking_id => booking_ids, :hidden => nil)
    #payment_methods_json_string = PaymentMethodItems.select("items.refund_sum as r, items.category_id as y,items.taxes as t").where(:created_at => from...to, :settlement_id => settlement_ids)
    #render :json => items

    render :json => "{\"items\":[#{items_json_string}], \"booking_items\":[#{booking_items_json_string}]}"
    #render :json => "[#{items_json_string}]"
  end
  
  def identify_printers
    Printr.new.identify
    render :nothing => true
  end
  
  def test_printers
    Printr.new(@current_vendor.vendor_printers.existing).identify
    render :nothing => true
  end
end
