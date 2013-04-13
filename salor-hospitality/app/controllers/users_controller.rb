# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class UsersController < ApplicationController

  before_filter :check_permissions
  before_filter :check_role_weight, :only => [:update, :show, :edit, :destroy] # those are only methods that work with an already saved user model

  def index
    @users = @current_vendor.users.existing
  end

  def new
    redirect_to '/saas/users/new' and return if defined?(ShSaas) == 'constant'
    @user = User.new
    @roles = @current_vendor.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
  end

  def show
    @user = get_model
    redirect_to users_path and return unless @user
  end

  def create
    @user = User.new(params[:user])
    @user.vendors = [@current_vendor]
    @user.default_vendor_id = @current_vendor.id if @user.default_vendor_id.nil? # the responsible form is not displayed when there is only 1 vendor in the company
    @user.company = @current_company
    @user.role = @current_user.role if @user.role.weight < @current_user.role_weight # prevent RESTful creation of an user with higher privileges than your own.
    if @user.save
      if @user.tables.empty?
        # assign all existing tables in case the tables select field was left empty, since not all users have the permissions to set a table, or it was forgotten to set them.
        @user.tables = @current_vendor.tables.existing.where(:enabled => true)
        @user.save
      end
      flash[:notice] = I18n.t("users.create.success")
      redirect_to users_path
    else
      @roles = @current_vendor.roles.existing.active
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      render(:new)
    end
  end

  def edit
    redirect_to "/saas/users/#{ params[:id] }/edit" and return if defined?(ShSaas) == 'constant'
    @user = get_model
    redirect_to users_path and return unless @user
    @roles = @current_vendor.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
    render :new
  end

  def update
    @user = get_model
    redirect_to users_path and return unless @user
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t("users.create.success")
      if @user == @current_user
        session[:locale] = I18n.locale = @user.language
      end
      redirect_to(users_path)
    else
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      @roles = @current_vendor.roles.existing.active
      render(:new)
    end
  end

  def destroy
    @user = get_model
    redirect_to users_path and return unless @user
    flash[:notice] = I18n.t("users.destroy.success")
    @user.hidden = true
    @user.password = "OLD #{ Time.now } #{ @user.password }"
    @user.save
    redirect_to users_path
  end
  
  def unlock_ip
    user = get_model
    user.update_attribute :current_ip, nil
    render :nothing => true
  end
  
  private
  
  def check_role_weight
    @user = get_model
    redirect_to users_path and return if @current_user.role.weight > @user.role.weight
  end
end
