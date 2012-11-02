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
    flash[:notice] = nil
    flash[:error] = nil
    render :layout => 'login'
  end

  def create
    subdomain = request.subdomain
    
    if request.subdomain.empty? or Company.existing.active.all? { |c| c.mode == 'local' }
      company = Company.existing.active.where( :mode => 'local').first
    else
      company = Company.existing.active.where( :subdomain => subdomain ).first
    end

    if company and company.mode == 'saas'
      auth_string = request.env['HTTP_AUTHORIZATION']
      auth_user_match = /Digest username="(.*?)"/.match(auth_string)
      auth_user = auth_user_match[1] if auth_user_match
      if company.subdomain != auth_user
        UserMailer.plain_message("User attempted to log into a foreign account", request, company).deliver if company.email
        company = nil
      end
    end

    if company
      user = company.users.existing.active.where(:password => params[:password]).first
    end
    
    if user
      if ( not user.role.permissions.include?('login_locking') ) or company.mode != 'local' or user.current_ip.nil? or user.current_ip == request.ip
        session[:user_id] = user.id
        session[:company_id] = user.company.id
        session[:vendor_id] = user.vendors.existing.first.id # unless session[:vendor_id] and Vendor.find_by_id(session[:vendor_id]).company_id == user.company.id
        user.update_attributes :current_ip => request.ip, :last_active_at => Time.now, :last_login_at => Time.now
        I18n.locale = user.language
        session[:admin_interface] = false
        flash[:error] = nil
        flash[:notice] = t('messages.hello_username', :name => user.login)
        UserMailer.plain_message("Login occurred", request, company).deliver if company.email
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
    redirect_to '/session/new'
  end
end
