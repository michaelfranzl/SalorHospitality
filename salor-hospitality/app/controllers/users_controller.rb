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
  
  after_filter :update_vendor_cache, :only => ['create','update','destroy']

  def index
    @vendors = @current_user.vendors.existing
  end

  def new
    redirect_to '/saas/users/new' and return if defined?(ShSaas) == 'constant'
    @user = User.new
    @roles = @current_company.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
    @vendors = @current_company.vendors.existing
  end

  def show
    @user = get_model
    @from, @to = assign_from_to(params)
    @user_logins = @user.user_logins.where(:created_at => @from..@to)
    redirect_to users_path and return unless @user
  end

  def create
    permitted = params.require(:user).permit :active,
        :login,
        :title,
        :password,
        :advertising_url,
        :role_id,
        :color,
        :language,
        :layout,
        :default_vendor_id,
        :screenlock_timeout,
        :maximum_shift_duration,
        :advertising_timeout,
        :track_time,
        :audio,
        :tables_array => [],
        :vendors_array => []

        
    @user = User.new permitted
    unless params[:vendor_array]
      @user.vendors = [@current_vendor]
    end
    unless @user.default_vendor_id
      # the responsible form is not displayed when there is only 1 vendor in the company. this must happen before save, since presence will be validated.
      @user.default_vendor_id = @current_vendor.id
    end
    @user.company = @current_company
    
    if @user.save
      @user.role_weight = @user.role.weight # initialization
      if @user.role_weight < @current_user.role_weight
        # gracefully prevent RESTful creation of an user with higher privileges than the current user, might be a hacking attempt
        @user.role = @current_user.role
      end
      if @user.tables.empty?
        # assign all existing tables in case the tables select field was left empty, since not all users have the permissions to set a table, or it was forgotten to set them.
        @user.tables = @current_vendor.tables.existing.where(:enabled => true)
      end
      @user.save
      flash[:notice] = I18n.t("users.create.success")
      redirect_to users_path
    else
      @roles = @current_company.roles.existing.active
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      @vendors = @current_company.vendors.existing
      render(:new)
    end
  end

  def edit
    redirect_to "/saas/users/#{ params[:id] }/edit" and return if defined?(ShSaas) == 'constant'
    @user = get_model
    unless @user
      flash[:error] = t('not_found')
      redirect_to users_path and return
    end
    @roles = @current_company.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
    @vendors = @current_company.vendors.existing
    render :new
  end

  def update
    @user = get_model
    unless @user
      flash[:error] = t('not_found')
      redirect_to(users_path) and return
    end
    
    if @user.default_vendor_id.nil?
      # the responsible form is not displayed when there is only 1 vendor in the company. this must happen before save, since presence will be validated.
      @user.default_vendor_id = @current_vendor.id
    end
    
    permitted = params.require(:user).permit :active,
        :login,
        :title,
        :password,
        :advertising_url,
        :role_id,
        :color,
        :language,
        :layout,
        :default_vendor_id,
        :screenlock_timeout,
        :maximum_shift_duration,
        :advertising_timeout,
        :track_time,
        :audio,
        :tables_array => [],
        :vendors_array => []
    
    if @user.update_attributes permitted
      @user.role_weight = @user.role.weight # update
      if @user.role_weight < @current_user.role_weight
        # gracefully prevent RESTful creation of an user with higher privileges than the current user, might be a hacking attempt
        @user.role = @current_user.role
      end
      @user.save
      flash[:notice] = I18n.t("users.create.success")
      redirect_to(users_path)
    else
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      @vendors = @current_company.vendors.existing
      @roles = @current_company.roles.existing.active
      @vendors = @current_company.vendors.existing
      render(:new)
    end
  end

  def destroy
    @user = get_model
    redirect_to users_path and return unless @user
    if @current_vendor.tables.existing.active.where(:active_user_id => @user.id).any?
      flash[:notice] = I18n.t("This user has active orders. Cannot delete.")
      redirect_to users_path
      return
    end
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
  
#   def record_history
#     @user.record_history(@user.previous_changes, params[:action], @current_user, @current_vendor, request.ip)
#   end
  
  def check_role_weight
    @user = get_model
    redirect_to users_path and return if @current_user.role.weight > @user.role.weight
  end
end
