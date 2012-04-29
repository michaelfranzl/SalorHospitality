# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class UsersController < ApplicationController

  before_filter :check_permissions

  def index
    @users = @current_company.users.existing
  end

  def new
    @user = User.new
    @tables = Table.all
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @user.company = @current_company
    @user.save ? redirect_to(users_path) : render(:new)
  end

  def edit
    @user = User.find(params[:id])
    @tables = Table.existing
    render :new
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user]) ? redirect_to(users_path) : render(:new)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_settings'
    end

end
