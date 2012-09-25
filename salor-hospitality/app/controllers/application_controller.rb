# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'net/http'
class ApplicationController < ActionController::Base
  helper :all
  before_filter :fetch_logged_in_user, :set_locale

  helper_method :logged_in?, :mobile?, :mobile_special?, :workstation?

  private

    def assign_from_to(p)
      begin
        f = Date.civil( p[:from][:year ].to_i,
                        p[:from][:month].to_i,
                        p[:from][:day  ].to_i) if p[:from]
        t = Date.civil( p[:to  ][:year ].to_i,
                        p[:to  ][:month].to_i,
                        p[:to  ][:day  ].to_i) + 1.day if p[:to]
      rescue
        flash[:error] = t(:invalid_date)
        f = Time.now.beginning_of_day
        t = Time.now.end_of_day
      end
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

    # the invoice view can contain 1 or 2 non-finished orders. if it contains 2 orders, and 1 is finished, then stay on the invoice view and just display the remaining order, otherwise go to the main (tables) view.
    def render_invoice_form(table)
      @orders = @current_vendor.orders.existing.where(:finished => false, :table_id => table.id)
      @cost_centers = @current_vendor.cost_centers.existing.active
      @taxes = @current_vendor.taxes.existing
      @tables = @current_vendor.tables.existing
      @bookings = @current_vendor.bookings.existing.where("`paid` = FALSE AND `from_date` < ? AND `to_date` > ?", Time.now, Time.now)
      if @orders.empty?
        table.update_attribute :user, nil if @orders.empty?
        render :js => "route('tables');" and return
      else
        render 'orders/render_invoice_form'
      end
    end

    def set_locale
      I18n.locale = @current_user ? @current_user.language : 'en'
    end

    def update_vendor_cache
      @current_vendor.update_cache
    end

    def check_permissions
      redirect_to '/' and return unless @current_user.role.permissions.include? "manage_#{ controller_name }"
    end

    def workstation?
      return false
      request.user_agent.nil? or request.user_agent.include?('Firefox') or request.user_agent.include?('MSIE') or request.user_agent.include?('Macintosh') or request.user_agent.include?('Chromium') or request.user_agent.include?('Chrome') or request.user_agent.include?('iPad')
    end

    def mobile?
      not workstation?
    end

    def mobile_special?
      request.user_agent.include?('iPad')
    end

    def neighbour_models(model_name, model_object)
      models = @current_vendor.send(model_name).existing.where(:finished => true)
      idx = models.index(model_object)
      previous_model = models[idx-1] if idx
      previous_model = model_object if previous_model.nil?
      next_model = models[idx+1] if idx
      next_model = model_object if next_model.nil?
      return previous_model, next_model
    end
    
end
