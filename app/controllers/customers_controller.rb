# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class CustomersController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @customers = @current_vendor.customers.existing
  end

  def new
    @customer = Customer.new
  end

  def edit
    @customer = get_model
    redirect_to customers_path and return unless @customer
    render :new
  end

  def create
    @customer = Customer.new(params[:customer])
    @customer.company = @current_company
    @customer.vendor = @current_vendor
    if @customer.save
      flash[:notice] = t('customers.create.success')
      redirect_to customers_path
    else
      render :action => 'new'
    end
  end

  def update
    @customer = get_model
    redirect_to customers_path and return unless @customer
    if @customer.update_attributes params[:customer]
      flash[:notice] = t('customers.create.success')
      redirect_to customers_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @customer = get_model
    redirect_to customers_path and return unless @customer
    @customer.update_attribute :hidden, true
    flash[:notice] = t('customers.destroy.success')
    redirect_to customers_path
  end
end
