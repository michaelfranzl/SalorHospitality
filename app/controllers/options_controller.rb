# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class OptionsController < ApplicationController
  def index
    @categories = @current_vendor.categories.active.existing
  end

  def new
    @option = Option.new
    @categories = @current_vendor.categories.active.existing
  end

  def create
    @categories = @current_vendor.categories.active.existing
    @option = Option.new(params[:option])
    @option.vendor = @current_vendor
    @option.company = @current_company
    @option.save ? redirect_to(options_path) : render(:new)
  end

  def edit
    @categories = @current_vendor.categories.active.existing
    @option = get_model
    render :new
  end

  def update
    @categories = @current_vendor.categories.active.existing
    @option = get_model
    success = @option.update_attributes(params[:option])
    success ? redirect_to(options_path) : render(:new)
  end

  def destroy
    @option = Option.find(params[:id])
    @option.update_attribute :hidden, true
    redirect_to options_path
  end

  def sort
    params['option'].each do |id|
      o = Option.find_by_id id
      o.position = params['option'].index(o.id.to_s) + 1
      o.save
    end
    render :nothing => true
  end

end
