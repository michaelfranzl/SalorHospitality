# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class StatisticCategoriesController < ApplicationController

  before_filter :check_permissions
  
  def index
    @statistic_categories = @current_vendor.statistic_categories.existing
  end

  def new
    @statistic_category = StatisticCategory.new
  end

  def create
    permitted = params.require(:statistic_category).permit :name
        
    @statistic_category = StatisticCategory.new permitted
    @statistic_category.vendor = @current_vendor
    @statistic_category.company = @current_company
    if @statistic_category.save
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to(statistic_categories_path)
    else
      render :new
    end
  end

  def edit
    @statistic_category = get_model
    redirect_to roles_path and return unless @statistic_category
    render :new
  end

  def update
    @statistic_category = get_model
    redirect_to roles_path and return unless @statistic_category
    
    permitted = params.require(:statistic_category).permit :name
    if @statistic_category.update_attributes permitted
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to statistic_categories_path
    else
      render :new
    end
  end

  def destroy
    @statistic_category = get_model
    redirect_to statistic_categories_path and return unless @statistic_category
    @statistic_category.update_attribute :hidden, true
    flash[:notice] = t('categories.destroy.success')
    redirect_to statistic_categories_path
  end

end
