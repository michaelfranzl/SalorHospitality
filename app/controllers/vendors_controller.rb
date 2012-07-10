# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

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
      :item_scribe => @current_user.role.permissions.include?("item_scribe")
    }
    render :js => "permissions = #{ permissions.to_json }; resources = #{ resources };"
  end
end
