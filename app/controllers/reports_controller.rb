# coding: UTF-8

# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2012-2013  Red (E) Tools LTD
# 
# See license.txt for the license applying to all files within this software.

class ReportsController < ApplicationController
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
end
