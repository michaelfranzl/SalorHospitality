# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class PaymentMethodsController < ApplicationController

  before_filter :check_permissions

  def index
    @payment_methods = @current_vendor.payment_methods.existing
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(params[:payment_method])
    @payment_method.vendor = @current_vendor
    @payment_method.company = @current_company
    if @payment_method.save
      flash[:notice] = t('payment_methods.create.success')
      redirect_to payment_methods_path
    else
      render :new
    end
  end

  def edit
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    render :new
  end

  def update
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    if @payment_method.update_attributes(params[:payment_method])
      flash[:notice] = t('payment_methods.create.success')
      redirect_to(payment_methods_path)
    else
      render(:new)
    end
  end

  def destroy
    @payment_method = get_model
    redirect_to roles_path and return unless @payment_method
    @payment_method.update_attribute :hidden, true
    flash[:notice] = t('payment_methods.destroy.success')
    redirect_to payment_methods_path
  end

end
