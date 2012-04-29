# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class TaxesController < ApplicationController
  def index
    @taxes = Tax.existing
  end

  def new
    @tax = Tax.new
  end

  def create
    @tax = Tax.new(params[:tax])
    @tax.save ? redirect_to(taxes_path) : render(:new)
  end

  def edit
    @tax = Tax.find(params[:id])
    render :new
  end

  def update
    @tax = Tax.find(params[:id])
    @tax.update_attributes(params[:tax]) ? redirect_to(taxes_path) : render(:new)
  end

  def destroy
    @tax = Tax.find(params[:id])
    @tax.update_attribute :hidden, true
    redirect_to taxes_path
  end

end
