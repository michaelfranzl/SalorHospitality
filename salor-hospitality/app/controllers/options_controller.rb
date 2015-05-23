# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class OptionsController < ApplicationController

  before_filter :check_permissions
  after_filter :update_vendor_cache, :only => ['create','update','destroy', 'sort']

  def index
    @categories = @current_vendor.categories.active.existing
  end

  def new
    @option = Option.new
    @categories = @current_vendor.categories.active.existing
    render 'new'
  end

  def create
    @categories = @current_vendor.categories.active.existing
    permitted = params.require(:option).permit :name,
      :price,
      :separate_ticket,
      :no_ticket,
      :set_categories => [],
      :images_attributes => [
        :file_data
      ]
        
    @option = Option.new permitted
    @option.vendor = @current_vendor
    @option.company = @current_company
    if @option.save
      @option.images.update_all :company_id => @option.company_id
      flash[:notice] = I18n.t("options.create.success")
      redirect_to options_path
    else
      render :new
    end
  end

  def edit
    @categories = @current_vendor.categories.active.existing
    @option = get_model
    redirect_to roles_path and return unless @option
    render :new
  end

  def update
    @categories = @current_vendor.categories.active.existing
    @option = get_model
    redirect_to roles_path and return unless @option
    
    permitted = params.require(:option).permit :name,
      :price,
      :separate_ticket,
      :no_ticket,
      :set_categories => [],
      :images_attributes => [
        :file_data
      ]
    
    if @option.update_attributes permitted
      @option.images.update_all :company_id => @option.company_id
      flash[:notice] = I18n.t("options.create.success")
      redirect_to options_path
    else
      render :new
    end
  end

  def destroy
    @option = get_model
    redirect_to roles_path and return unless @option
    @option.hide(@current_user.id)
    flash[:notice] = I18n.t("options.destroy.success")
    redirect_to options_path
  end

  def sort
    params['option'].each do |id|
      o = @current_vendor.options.find_by_id(id)
      o.position = params['option'].index(o.id.to_s) + 1
      o.save
    end
    render :nothing => true
  end
end
