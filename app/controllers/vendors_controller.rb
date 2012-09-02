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

  # Switches the current vendor and redirects to somewhere else
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
    @vendor ? render(:new) : redirect_to(vendors_path)
  end

  def update
    @vendor = get_model
    redirect_to vendors_path and return unless @vendor
    unless @vendor.update_attributes params[:vendor]
      @vendor.images.reload
      render(:edit) and return 
    end
    printr = Printr.new(@vendor.vendor_printers.existing)
    printr.identify
    redirect_to vendors_path
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new params[:vendor]
    @vendor.company = @current_company
    if @vendor.save
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
      :see_item_notifications_delivery => @current_user.role.permissions.include?("see_item_notifications_delivery"),
      :see_item_notifications_preparation => @current_user.role.permissions.include?("see_item_notifications_preparation"),
      :see_item_notifications_vendor => @current_user.role.permissions.include?("see_item_notifications_vendor"),
      :manage_payment_methods => @current_user.role.permissions.include?("manage_payment_methods"),
      :manage_customers => @current_user.role.permissions.include?("manage_customers")
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
    order_ids = @current_vendor.orders.where(:finished_at => from..to, :finished => true, :paid => true).collect { |o| o.id }
    items = Item.select("refund_sum, category_id, taxes").where(:created_at => from...to, :order_id => order_ids, :hidden => nil)
    items_json_string = items.collect{|i| "{\"r\":#{i.refund_sum ? i.refund_sum : 'null'},\"t\":#{i.taxes.to_json},\"y\":#{i.category_id}}" }.join(',')
    items_json_string.gsub! "\n", '\n'
    
    booking_ids = @current_vendor.bookings.where(:finished_at => from..to, :finished => true).collect { |o| o.id }
    booking_items = BookingItem.select("refund_sum, room_id, taxes").where(:booking_id => booking_ids, :hidden => nil)
    booking_items_json_string = booking_items.collect{|i| "{\"r\":#{i.refund_sum ? i.refund_sum : 'null'},\"t\":#{i.taxes.to_json},\"m\":#{i.room_id}}" }.join(',')
    booking_items_json_string.gsub! "\n", '\n'
    
    #payment_methods_json_string = PaymentMethodItems.select("items.refund_sum as r, items.category_id as y,items.taxes as t").where(:created_at => from...to, :settlement_id => settlement_ids)
    #render :json => items

    render :json => "{\"items\":[#{items_json_string}], \"booking_items\":[#{booking_items_json_string}]}"
    #render :json => "[#{items_json_string}]"
  end
  
  def identify_printers
    Printr.new.identify
    render :nothing => true
  end
end
