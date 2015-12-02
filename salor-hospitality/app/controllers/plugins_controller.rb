# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PluginsController < ApplicationController
  
  before_filter :check_permissions

  def index
    @plugins = @current_vendor.plugins.existing
  end

  def new
    @plugin = Plugin.new
  end
  
  def edit
    @plugin = @current_vendor.plugins.find_by_id(params[:id])
    render :new
  end

  def create
    @plugin = Plugin.new
    @plugin.company = @current_company
    @plugin.vendor = @current_vendor

    if @plugin.save
      if params[:plugin].nil?
        @plugin.hide(@current_user.id)
        redirect_to plugins_path
        return
      end
      @plugin.filename = params[:plugin][:filename]
      @plugin.unzip
      redirect_to plugins_path
    else
      render :new
    end
  end

  def update
    permitted = params.require(:plugin).permit!
      
    @plugin = @current_vendor.plugins.find_by_id(params[:id])
    if @plugin.update_attributes(permitted)
      if params[:plugin][:filename]
        @plugin.unzip
      end
      redirect_to plugins_path
    else
      render :edit
    end
  end

  def destroy
    @plugin = @current_vendor.plugins.find_by_id(params[:id])
    @plugin.hide(@current_user.id)
    redirect_to plugins_path
  end

end