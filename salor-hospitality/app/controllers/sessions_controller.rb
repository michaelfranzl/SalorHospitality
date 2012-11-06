# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :set_locale, :except => :destroy

  def new
    @submit_path = session_path
    render :layout => 'login'
  end
  
  def new_customer
    @submit_path = session_path
    render :layout => 'login'
  end

  def create
    # Simple login
    company = Company.existing.active.where( :mode => 'local').first
    
    if params[:mode] == 'user'
      if company
        user = company.users.existing.active.where(:password => params[:password]).first
      end
      if user
        if ( not user.role.permissions.include?('login_locking') ) or company.mode != 'local' or user.current_ip.nil? or user.current_ip == request.ip
          session[:user_id] = user.id
          session[:company_id] = user.company_id
          session[:vendor_id] = user.vendors.existing.first.id
          user.update_attributes :current_ip => request.ip, :last_active_at => Time.now, :last_login_at => Time.now
          I18n.locale = user.language
          session[:admin_interface] = false
          flash[:error] = nil
          flash[:notice] = t('messages.hello_username', :name => user.login)
          UserMailer.plain_message("Login occurred #{params[:password]}", request, company).deliver if company.email and company.mode == 'demo' and SalorHospitality::Application::SH_DEBIAN_SITED != 'none'
          redirect_to orders_path and return
        else
          flash[:error] = t('messages.user_account_is_currently_locked')
          flash[:notice] = nil
          render :new, :layout => 'login' and return
        end
      else
        flash[:error] = t :wrong_password
        render :new, :layout => 'login' and return
      end
      
    elsif params[:mode] == 'customer'
      if company
        customer = company.customers.existing.active.where(:password => params[:password]).first
      end
      if customer
        session[:customer_id] = customer.id
        session[:company_id] = customer.company_id
        session[:vendor_id] = customer.vendor_id
        customer.update_attributes :current_ip => request.ip, :last_active_at => Time.now, :last_login_at => Time.now
        I18n.locale = customer.language
        flash[:error] = nil
        flash[:notice] = t('messages.hello_username', :name => customer.login)
        redirect_to orders_path and return
      else
        flash[:error] = t :wrong_password
        render :new, :layout => 'login' and return
      end
    end
  end

  def request_specs_login
    create
  end

  def destroy
    @current_user.update_attributes :last_logout_at => Time.now, :last_active_at => Time.now, :current_ip => nil
    @current_user = session[:user_id] = nil
    redirect_to '/'
  end

  def exception_test
    nil.throw_whiny_nil_error_please
  end

  def permission_denied
    render :layout => 'login'
  end

  def catcher
    redirect_to 'new'
  end
end
