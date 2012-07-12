# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class TablesController < ApplicationController

  before_filter :check_permissions, :except => [:index, :show]

  respond_to :html, :js
  
  def index
    @tables = @current_user.tables.where(:vendor_id => @current_vendor).existing
    @last_finished_order = @current_vendor.orders.existing.where(:finished => true).last
    respond_with do |wants|
      wants.html
      wants.js
    end
  end

  def show
    @table = get_model
    redirect_to roles_path and return unless @table
    @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => params[:id])
    if params[:order_id] and not params[:order_id].empty?
      @order = @current_vendor.orders.find_by_id(params[:order_id])
      render 'orders/go_to_order_form'
    else
      if @orders.size > 1
        @cost_centers = @current_vendor.cost_centers.existing.active
        @taxes = @current_vendor.taxes.existing
        @bookings = @current_vendor.bookings.existing.where("`paid` = FALSE AND `from` < ? AND `to` > ?", Time.now, Time.now)
        render 'orders/go_to_invoice_form'
      else
        @order = @orders.first
        render 'orders/go_to_order_form'
      end
    end
  end

  def new
    @table = Table.new
  end

  def create
    if @current_vendor.max_tables and @current_vendor.max_tables < @current_vendor.tables.existing.count
      flash[:notice] = t('tables.create.license_limited', :count => @current_vendor.max_tables)
      redirect_to tables_path and return
    end
    @table = Table.new(params[:table])
    @table.vendor = @current_vendor
    @table.company = @current_company
    if @table.save
      @current_vendor.users.each do |u|
        u.tables << @table
      end
      flash[:notice] = t('tables.create.success')
      redirect_to tables_path
    else
      render :new
    end
  end

  def edit
    @table = get_model
    redirect_to tables_path and return unless @table
    render :new
  end

  def update
    @table = get_model
    redirect_to tables_path and return unless @table
    success = @table.update_attributes(params[:table])
    if success
      flash[:notice] = t('tables.create.success')
      redirect_to tables_path
    else
      render :new
    end
  end

  def update_coordinates
    @table = get_model
    @table.update_attributes(params[:table])
    render :nothing => true
  end

  def destroy
    @table = get_model
    redirect_to tables_path and return unless @table
    @table.hidden = true
    @table.name = "DEL#{(rand(99999) + 10000).to_s[0..4]}#{@table.name}"
    @table.update_attribute :hidden, true
    @table.update
    flash[:notice] = t('tables.destroy.success')
    redirect_to tables_path
  end

  def mobile
    @tables = @current_user.tables.existing
  end

end
