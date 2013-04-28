# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SessionsController < ApplicationController

  skip_before_filter :fetch_logged_in_user, :except => [:destroy, :test_mail]
  
  def show
    redirect_to '/' and return
  end

  def new
    #session[:user_id] = session[:customer_id] = @current_user = @current_customer = nil
    @company = Company.existing.active.where(:mode => 'local').first
    @vendor = @company.vendors.existing.first
    session[:customer_id] = @current_customer = nil
    @submit_path = session_path
    render :layout => 'login'
  end
  
  def new_customer
    @company = Company.existing.active.where(:mode => 'local').first
    @vendor = @company.vendors.existing.first
    session[:user_id] = session[:customer_id] = @current_user = @current_customer = nil
    @submit_path = session_path
    render :layout => 'login'
  end

  def create
    # Simple local login
    company = Company.existing.active.where(:mode => 'local').first
    
    if params[:mode] == 'user'
      if company
        user = company.users.existing.active.where(:password => params[:password]).first
      end
      if user
        if ( not user.role.permissions.include?('login_locking') ) or company.mode != 'local' or user.current_ip.nil? or user.current_ip == request.ip
          vendor = user.vendors.existing.first
          session[:user_id] = user.id
          session[:company_id] = user.company_id
          if user.default_vendor_id
            session[:vendor_id] = user.default_vendor_id
          else
            session[:vendor_id] = vendor.id
          end
          session[:locale] = I18n.locale = user.language
          user.update_attributes :current_ip => request.ip, :last_active_at => Time.now, :last_login_at => Time.now
          session[:admin_interface] = false
          flash[:error] = nil
          flash[:notice] = t('messages.hello_username', :name => user.login)
          
          if vendor and vendor.enable_technician_emails and vendor.technician_email and company.mode == 'demo' and SalorHospitality::Application::SH_DEBIAN_SITEID != 'none'
            UserMailer.technician_message(vendor, "Login to #{ company.name }", '', request).deliver
          end
          redirect_to orders_path and return
        else
          flash[:error] = t('messages.user_account_is_currently_locked')
          flash[:notice] = nil
          redirect_to '/' and return
        end
      else
        flash[:error] = t :wrong_password
        redirect_to '/' and return
      end
      
    elsif params[:mode] == 'customer'
      if company
        customer = company.customers.existing.active.where(:password => params[:password]).first
      end
      if customer
        session[:customer_id] = customer.id
        session[:company_id] = customer.company_id
        session[:vendor_id] = customer.vendor_id
        session[:locale] = customer.language
        customer.update_attributes :current_ip => request.ip, :last_active_at => Time.now, :last_login_at => Time.now
        I18n.locale = customer.language
        flash[:error] = nil
        flash[:notice] = t('messages.hello_username', :name => customer.login)
        redirect_to orders_path and return
      else
        flash[:error] = t :wrong_password
        redirect_to new_customer_session_path and return
      end
    end
  end

  def request_specs_login
    #create
  end

  def destroy
    if @current_user
      session[:ad_url] = nil
      session[:ad_url] = @current_user.advertising_url if @current_user.advertising_url and not @current_user.advertising_url.empty?
      @current_user.update_attributes :last_logout_at => Time.now, :last_active_at => Time.now, :current_ip => nil
      redirect_to '/'
    elsif @current_customer
      @current_customer.update_attributes :last_logout_at => Time.now, :last_active_at => Time.now, :current_ip => nil
      redirect_to new_customer_session_path
    end
    @current_user = @current_customer = session[:user_id] = session[:customer_id] = nil
  end

  def test_exception
    nil.throw_whiny_nil_error # this method does not exist, which throws an exception.
  end
  
  def email
    subject = params[:s]
    subject ||= "Test"
    message = params[:m]
    message ||= "Message"
    vendor = Vendor.find_by_id(session[:vendor_id])
    if vendor and vendor.technician_email and vendor.enable_technician_emails
      UserMailer.technician_message(vendor, subject, message).deliver
      Email.create :receipient => vendor.technician_email, :subject => subject, :body => message, :vendor_id => vendor.id, :company_id => vendor.company_id, :technician => true
    else
      logger.info "[TECHNICIAN] #{subject} #{message}"
    end
    render :nothing => true
  end
  
  def test_email
    subject = params[:s]
    subject ||= "Test"
    message = params[:m]
    message ||= "Message"
    company = Company.find_by_id(session[:company_id])
    vendor = Vendor.find_by_id(session[:vendor_id])
    if vendor and vendor.technician_email and vendor.enable_technician_emails
      UserMailer.technician_message(vendor, subject, message).deliver
    else
      logger.info "[TECHNICIAN] #{subject} #{message}"
    end
    redirect_to '/'
  end

  def permission_denied
    render :layout => 'login'
  end

  def catcher
    redirect_to 'new'
  end
end
