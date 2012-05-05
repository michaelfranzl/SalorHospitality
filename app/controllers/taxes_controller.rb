# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class TaxesController < ApplicationController
  def index
    @taxes = @current_vendor.taxes.existing
  end

  def new
    @tax = Tax.new
  end

  def create
    @tax = get_model
    redirect_to taxes_path and return unless @tax
    @tax.save ? redirect_to(taxes_path) : render(:new)
  end

  def edit
    @tax = get_model
    render :new
  end

  def update
    @tax = get_model
    redirect_to taxes_path and return unless @tax
    @tax.update_attributes(params[:tax]) ? redirect_to(taxes_path) : render(:new)
  end

  def destroy
    @tax = get_model
    redirect_to taxes_path and return unless @tax
    @tax.update_attribute :hidden, true
    redirect_to taxes_path
  end

end
