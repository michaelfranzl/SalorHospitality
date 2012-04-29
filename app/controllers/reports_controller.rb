# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.
class ReportsController < ApplicationController
  helper :all
  before_filter :fetch_logged_in_user, :select_current_company, :set_locale
  helper_method :logged_in?, :mobile?, :workstation?, :saas_variant?, :saas_basic_varian?, :saas_plus_variant?, :saas_pro_variant?, :local_variant?, :demo_variant?, :mobile_special?
  
  def index
    @from, @to = assign_from_to(params)
    @from = @from ? @from.beginning_of_day : DateTime.now.beginning_of_day
    @to = @to ? @to.end_of_day : @from.end_of_day
    if params[:usb_device] and not params[:usb_device].empty? and File.exists? params[:usb_device] then
      @report = Report.new
      @report.dump_all(@from,@to,params[:usb_device])
      flash[:notice] = "Complete"
    end
  end
  private
  def assign_from_to(p)
    begin
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) if p[:to]
    rescue
      f = t = nil
    end
    #f ||= DateTime.now
    #t ||= DateTime.now
    return f, t
  end
end
