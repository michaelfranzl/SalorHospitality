# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class CostCentersController < ApplicationController

  before_filter :check_permissions

  def index
    @cost_centers = @current_vendor.cost_centers.existing.active
  end

  def new
    @cost_center = CostCenter.new
  end

  def create
    @cost_center = CostCenter.new(params[:cost_center])
    @cost_center.vendor = @current_vendor
    @cost_center.company = @current_company
    if @cost_center.save
      flash[:notice] = t('cost_centers.create.success')
      redirect_to cost_centers_path
    else
      render :new
    end
  end

  def edit
    @cost_center = get_model
    redirect_to roles_path and return unless @cost_center
    render :new
  end

  def update
    @cost_center = get_model
    redirect_to roles_path and return unless @cost_center
    if @cost_center.update_attributes(params[:cost_center])
      flash[:notice] = t('cost_centers.create.success')
      redirect_to(cost_centers_path)
    else
      render(:new)
    end
  end

  def destroy
    @cost_center = get_model
    redirect_to roles_path and return unless @cost_center
    @cost_center.update_attribute :hidden, true
    flash[:notice] = t('cost_centers.destroy.success')
    redirect_to cost_centers_path
  end

end
