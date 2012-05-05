# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class TablesController < ApplicationController

  def index
    @tables = @current_user.tables.existing
    @last_finished_order = @current_vendor.orders.existing.where(:finished => true).last
    respond_to do |wants|
      wants.html
      wants.js
    end
  end

  def show
    @table = get_model
    @cost_centers = @current_vendor.cost_centers.existing.active
    @taxes = @current_vendor.taxes.existing.active
    @orders = @current_vendor.orders.existing.where(:table_id => @table.id, :finished => false )
    if @orders.size > 1
      render 'orders/go_to_invoice_form'
    else
      @order = @orders.first
      render 'orders/go_to_order_form'
    end
  end

  def new
    @table = Table.new
  end

  def create
    @table = Table.new(params[:table])
    @table.vendor = @current_vendor
    @table.company = @current_company
    if @table.save
      @current_vendor.users.each do |u|
        u.tables << @table
      end
      flash[:notice] = t('articles.create.success')
      redirect_to tables_path
    else
      render :new
    end
  end

  def edit
    @table = get_model
    render :new
  end

  def update
    @table = get_model
    success = @table.update_attributes(params[:table])
    respond_to do |wants|
      wants.html do
        if success
          flash[:notice] = t('tables.create.success')
          redirect_to tables_path
        else
          render :new
        end
      end
      wants.js { render :nothing => true }
    end
  end

  def destroy
    @table = get_model
    @table.update_attribute :hidden, true
    flash[:notice] = t('tables.destroy.success')
    redirect_to tables_path
  end

  def mobile
    @tables = @current_user.tables.existing
  end

end
