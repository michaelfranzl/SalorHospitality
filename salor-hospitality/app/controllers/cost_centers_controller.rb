# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class CostCentersController < ApplicationController

  before_filter :check_permissions

  def index
    @cost_centers = @current_vendor.cost_centers.existing
  end

  def new
    @cost_center = CostCenter.new
  end

  def create
    permitted = params.require(:cost_center).permit :name,
      :description,
      :no_payment_methods
    @cost_center = CostCenter.new permitted
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
    permitted = params.require(:cost_center).permit :name,
      :description,
      :no_payment_methods
    if @cost_center.update_attributes permitted
      flash[:notice] = t('cost_centers.create.success')
      redirect_to(cost_centers_path)
    else
      render(:new)
    end
  end

  def destroy
    @cost_center = get_model
    redirect_to roles_path and return unless @cost_center
    @cost_center.hide(@current_user)
    flash[:notice] = t('cost_centers.destroy.success')
    redirect_to cost_centers_path
  end
end
