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
    @vendors = @current_company.vendors.existing
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
      :see_item_notifications => @current_user.role.permissions.include?("see_item_notifications")
    }
    render :js => "permissions = #{ permissions.to_json }; resources = #{ resources };"
  end
end
