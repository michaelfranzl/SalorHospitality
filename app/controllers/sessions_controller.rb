# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale

  def new
    #@users = User.all
    render :layout => 'login'
  end

  def create
    @current_user = User.where(:password => params[:password], :active => true, :hidden => false).first
    if @current_user
      # set these variables for the first time. they will be re-set on each new request by ApplicationController::fetch_logged_in_user
      session[:user_id] = @current_user.id
      @current_company = @current_user.company
      session[:company_id] = @current_company.id
      session[:vendor_id] = @current_user.vendors.existing.first.id unless session[:vendor_id]
      
      I18n.locale = @current_user.language
      session[:admin_interface] = workstation? # admin panel per default on on workstation
      flash[:error] = nil
      flash[:notice] = t('messages.hello_username', :name => @current_user.login)

      redirect_to orders_path
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
