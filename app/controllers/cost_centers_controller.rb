# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class CostCentersController < ApplicationController
  def index
    @cost_centers = CostCenter.existing
  end

  def new
    @cost_center = CostCenter.new
  end

  def create
    @cost_center = CostCenter.new(params[:cost_center])
    @cost_center.save ? redirect_to(cost_centers_path) : render(:new)
  end

  def edit
    @cost_center = CostCenter.find(params[:id])
    render :new
  end

  def update
    @cost_center = CostCenter.find(params[:id])
    @cost_center.update_attributes(params[:cost_center]) ? redirect_to(cost_centers_path) : render(:new)
  end

  def destroy
    @cost_center = CostCenter.find(params[:id])
    @cost_center.destroy
    redirect_to cost_centers_path
  end

end
