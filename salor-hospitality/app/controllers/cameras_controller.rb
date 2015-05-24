# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class CamerasController < ApplicationController

  before_filter :check_permissions

  def index
    @cameras = @current_vendor.cameras.existing
  end

  def new
    @camera = Camera.new
  end
  
  def show
    @camera = get_model
  end

  def create
    permitted = params.require(:camera).permit :name,
      :description,
      :host_internal,
      :host_external,
      :port,
      :url_snapshot,
      :url_stream,
      :active
        
    @camera = Camera.new permitted
    @camera.vendor = @current_vendor
    @camera.company = @current_company
    if @camera.save
      flash[:notice] = t('cameras.create.success')
      redirect_to cameras_path
    else
      render :new
    end
  end

  def edit
    @camera = get_model
    redirect_to roles_path and return unless @camera
    render :new
  end

  def update
    @camera = get_model
    redirect_to roles_path and return unless @camera
    
    permitted = params.require(:camera).permit :name,
      :description,
      :host_internal,
      :host_external,
      :port,
      :url_snapshot,
      :url_stream,
      :active
    
    if @camera.update_attributes permitted
      flash[:notice] = t('cameras.create.success')
      redirect_to(cameras_path)
    else
      render(:new)
    end
  end

  def destroy
    @camera = get_model
    redirect_to roles_path and return unless @camera
    @camera.update_attribute :hidden, true
    flash[:notice] = t('cameras.destroy.success')
    redirect_to cameras_path
  end
end
