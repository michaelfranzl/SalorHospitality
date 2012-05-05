# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale

  def new
    @users = User.all
    render :layout => 'login'
  end

  def create
    @current_user = User.where(:password => params[:password], :active => true, :hidden => false).first
    if @current_user
      # set these variables for the first time. they will be re-set on each new request by ApplicationController::fetch_logged_in_user
      session[:user_id] = @current_user.id
      @current_company = @current_user.company
      session[:company_id] = @current_company.id
      
      I18n.locale = @current_user.language
      session[:admin_interface] = workstation? # admin panel per default on on workstation
      flash[:error] = nil
      flash[:notice] = t('messages.hello_username', :name => @current_user.login)
      if session[:vendor_id]
        redirect_to orders_path
      else
        session[:vendor_id] = @current_company.vendors.existing.first.id
        redirect_to vendors_path
      end
      #check_product_key
    else
      flash[:error] = t :wrong_password
      render :new, :layout => 'login'
    end
  end

  def request_specs_login
    create
  end

  def destroy
    @current_user = session[:user_id] = nil
    redirect_to '/session/new'
  end

  def exception_test
    nil.throw_whiny_nil_error_please
  end

  def permission_denied
    render :layout => 'login'
  end

  def catcher
    redirect_to '/session/new'
  end
end
