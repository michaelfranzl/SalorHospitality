# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

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
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = t('role.create.success')
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def update
    @role = get_model
    redirect_to roles_path and return unless @role
    if @role.update_attributes params[:role]
      flash[:notice] = t('role.create.success')
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

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_settings'
    end
end
