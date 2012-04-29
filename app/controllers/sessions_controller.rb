# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale

  def new
    @users = User.all
  end

  def create
    @current_user = User.where(:password => params[:password], :active => true, :hidden => false).first
    @users = User.all
    if @current_user
      session[:user_id] = @current_user
      I18n.locale = @current_user.language
      session[:admin_interface] = !mobile? # admin panel per default on on workstation
      flash[:error] = nil
      flash[:notice] = nil
      check_product_key
      redirect_to '/orders'
    else
      flash[:error] = t :wrong_password
      render :new
    end
  end

  def destroy
    @current_user = session[:user_id] = nil
    redirect_to '/'
  end

  def exception_test
    nil.throw_whiny_nil_error_please
  end

  def catcher
    redirect_to '/'
  end
end
