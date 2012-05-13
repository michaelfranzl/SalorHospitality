# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class UsersController < ApplicationController

  before_filter :check_permissions

  def index
    @users = @current_vendor.users.existing
  end

  def new
    @user = User.new
    @roles = @current_vendor.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
  end

  def show
    @user = get_model
    redirect_to user_path and return unless @user
  end

  def create
    @user = User.new(params[:user])
    @user.vendors = [@current_vendor]
    @user.company = @current_company
    if @user.save
      flash[:notice] = I18n.t("users.create.success")
      redirect_to users_path
    else
      @roles = @current_vendor.roles.existing.active
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      render(:new)
    end
  end

  def edit
    @user = get_model
    redirect_to user_path and return unless @user
    @roles = @current_vendor.roles.existing.active
    @tables = @current_vendor.tables.existing.where(:enabled => true)
    render :new
  end

  def update
    @user = get_model
    redirect_to user_path and return unless @user
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t("users.create.success")
      redirect_to(users_path)
    else
      @tables = @current_vendor.tables.existing.where(:enabled => true)
      @roles = @current_vendor.roles.existing.enabled
      render(:new)
    end
  end

  def destroy
    @user = get_model
    redirect_to user_path and return unless @user
    flash[:notice] = I18n.t("users.destroy.success")
    @user.update_attribute :hidden, true
    redirect_to users_path
  end
end
