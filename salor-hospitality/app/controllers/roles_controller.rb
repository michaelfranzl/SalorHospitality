# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class RolesController < ApplicationController

  before_filter :check_permissions

  def index
    @roles = @current_vendor.roles.existing
  end

  def new
    @role = Role.new
  end

  def edit
    @role = get_model
    redirect_to roles_path and return unless @role
    render :new
  end

  def create
    permitted = params.require(:role).permit :name,
        :weight,
        :permissions => []
    @role = Role.new permitted
    @role.company = @current_company
    @role.vendor = @current_vendor
    if @role.save
      flash[:notice] = t('roles.create.success')
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def update
    @role = get_model
    redirect_to roles_path and return unless @role
    permitted = params.require(:role).permit :name,
        :weight,
        :permissions => []
    if @role.update_attributes permitted
      @current_company.users.where(:role_id => @role.id).update_all :role_weight => @role.weight
      flash[:notice] = t('roles.create.success')
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @role = get_model
    redirect_to roles_path and return unless @role
    @role.update_attribute :hidden, true
    flash[:notice] = t('roles.destroy.success')
    redirect_to roles_path
  end
end
