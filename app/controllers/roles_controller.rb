# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.

class RolesController < ApplicationController

  before_filter :check_permissions

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
    render :new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes params[:role]
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  private

    def check_permissions
      redirect_to '/' if not @current_user.role.permissions.include? 'manage_settings'
    end
end
