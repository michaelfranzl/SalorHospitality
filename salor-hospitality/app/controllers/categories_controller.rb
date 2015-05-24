# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class CategoriesController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy', 'sort']
  
  def index
    @categories = @current_vendor.categories.existing.positioned
  end

  def new
    @category = Category.new
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active.where('role_weight > 0')
    @printers = @current_vendor.vendor_printers.existing
  end

  def create
    if @current_vendor.max_categories and @current_vendor.max_categories < @current_vendor.categories.existing.count
      flash[:notice] = t('categories.create.license_limited', :count => @current_vendor.max_categories)
      redirect_to categories_path and return
    end
    
    
    params[:category][:icon] = 'custom' if (params[:category][:images_attributes] and params[:category][:images_attributes]['0'][:file_data])
    permitted = params.require(:category).permit :name,
      :preparation_user_id,
      :vendor_printer_id,
      :separate_print,
      :icon,
      :color,
      :images_attributes => [
        :file_data
      ]
        
    @category = Category.new permitted
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active.where('role_weight > 0')
    @printers = @current_vendor.vendor_printers.existing
    @category.vendor = @current_vendor
    @category.company = @current_company
    if @category.save then
      #@category.images.update_all :company_id => @category.company_id
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to(categories_path)
    else
      render :new
    end
  end

  def edit
    @category = get_model
    redirect_to categories_path and return unless @category
    @taxes = @current_vendor.taxes.existing
    @users = @current_vendor.users.existing.active.where('role_weight > 0')
    @printers = @current_vendor.vendor_printers.existing
    render :new
  end

  def update
    @category = get_model
    redirect_to categories_path and return unless @category
    
    params[:category][:icon] = 'custom' if (params[:category][:images_attributes] and params[:category][:images_attributes]['0'][:file_data])
    permitted = params.require(:category).permit :name,
      :preparation_user_id,
      :vendor_printer_id,
      :separate_print,
      :icon,
      :color,
    :images_attributes => [
      :file_data
    ]
    
    if @category.update_attributes permitted
      #@category.images.update_all :company_id => @category.company_id
      flash[:notice] = I18n.t("categories.create.success")
      redirect_to categories_path
    else
      @taxes = @current_vendor.taxes.existing
      @users = @current_vendor.users.existing.active.where('role_weight > 0')
      @printers = @current_vendor.vendor_printers.existing
      render :new
    end
  end

  def destroy
    @category = get_model
    redirect_to roles_path and return unless @category
    @category.update_attribute :hidden, true
    flash[:notice] = t('categories.destroy.success')
    redirect_to categories_path
  end

  def sort
    @categories = @current_vendor.categories.existing.active.where("id IN (#{params[:category].join(',')})")
    Category.sort(@categories,params[:category])
    render :nothing => true
  end

end
