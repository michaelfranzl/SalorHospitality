# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
require 'net/http'
class ApplicationController < ActionController::Base

  helper :all
  before_filter :fetch_logged_in_user, :set_locale

  helper_method :logged_in?, :mobile?, :mobile_special?, :workstation?
  helper_method :saas_variant?, :saas_pro_variant?, :local_variant?, :demo_variant?

  private

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) + 1.day if p[:to]
      return f, t
    end

    def local_request?
      false
    end

    def fetch_logged_in_user
      @current_user = User.find_by_id session[:user_id] if session[:user_id]
      @current_company = @current_user.company if @current_user
      @current_vendor = Vendor.existing.find_by_id session[:vendor_id] if session[:vendor_id]
      session[:vendor_id] = nil and session[:company_id] = nil unless @current_vendor

      # we need these for the history observer because we don't have control at the time
      # the activerecord callbacks run, and anyway controller instance variables wouldn't
      # be in scope...
      $User = @current_user
      $Request = request
      $Params = params

      redirect_to new_session_path unless @current_user and @current_vendor
    end

    def get_model
      if params[:id]
        model = controller_name.classify.constantize.accessible_by(@current_user).existing.find_by_id(params[:id])
        if model.nil?
          flash[:error] = t('not_found')
        end
      end
      model
    end

    def set_locale
      I18n.locale = @current_user ? @current_user.language : 'en'
    end

    def update_vendor_cache
      @current_vendor.update_cache
    end

    def check_permissions
      redirect_to '/' unless @current_user.role.permissions.include? "manage_settings" #{ controller_name }"
    end

    def workstation?
      request.user_agent.nil? or request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh') or request.user_agent.include?('Chromium') or request.user_agent.include?('Chrome') or request.user_agent.include?('iPad')
    end

    def mobile?
      not workstation?
    end

    def mobile_special?
       request.user_agent.include?('iPad')
    end

    def saas_variant?
      @current_vendor.mode == 'saas' or @current_vendor.mode == 'saas_basic' or @current_vendor.mode == 'saas_plus' or @current_vendor.mode == 'saas_pro' if @current_vendor
    end

    def saas_basic_variant?
      @current_vendor.mode == 'saas_basic' if @current_vendor
    end

    def saas_plus_variant?
      @current_vendor.mode == 'saas_plus' if @current_vendor
    end

    def saas_pro_variant?
      @current_vendor.mode == 'saas_pro' if @current_vendor
    end

    def demo_variant?
      @current_vendor.mode == 'demo' if @current_vendor
    end

    def local_variant?
      @current_vendor.mode.nil? if @current_vendor
    end

    def check_product_key
      # Removing this code is an act of piracy, systems found with this block tampered with will be subject to prosecution in violation of international Digital Rights laws.
      resp = Net::HTTP.get(URI("http://updates.red-e.eu/files/get_translations?file_id=12&p=#{ /(..):(..):(..):(..):(..):(..)/.match(`/sbin/ifconfig eth0`.split("\n")[0])[1..6].join } "))
      begin
        json = JSON.parse(resp)
        if not json["success"] == true then
          exit
        end
      rescue;end
    end

end
