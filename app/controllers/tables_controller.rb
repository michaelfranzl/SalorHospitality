# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class TablesController < ApplicationController

  before_filter :check_permissions, :except => [:index, :show]

  respond_to :html, :js
  
  def index
    @tables = @current_user.tables.where(:vendor_id => @current_vendor).existing.order(:name)
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
    flash[:notice] = t('tables.destroy.success')
    redirect_to tables_path
  end

  def mobile
    @tables = @current_user.tables.existing
  end

end
