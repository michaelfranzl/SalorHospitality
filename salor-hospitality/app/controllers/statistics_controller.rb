# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class StatisticsController < ApplicationController

  before_filter :check_permissions

  def index
    @from, @to = assign_from_to(params)
    @from = @from ? @from.beginning_of_day : 1.week.ago.beginning_of_day
    @to = @to ? @to.end_of_day : DateTime.now
    @settlements = Settlement.where(:created_at => @from..@to, :finished => true).existing
    @settlement_ids = @settlements.collect{ |s| s.id }
    @taxes = @current_vendor.taxes.existing
    @payment_methods = @current_vendor.payment_methods.existing.where(:change => false)
    @cost_centers = @current_vendor.cost_centers.existing
    cost_center_ids = @cost_centers.collect{ |cc| cc.id }
    @selected_cost_center = params[:cost_center_id] ? @current_vendor.cost_centers.existing.find_by_id(params[:cost_center_id]) : nil
    @scids = @selected_cost_center ? @selected_cost_center.id : ([cost_center_ids] + [nil]).flatten
    @tables = @current_vendor.tables.existing.active
    @categories = @current_vendor.categories.existing
    @statistic_categories = @current_vendor.statistic_categories.existing
    @payment_methods = @current_vendor.payment_methods.existing
    test = I18n.t :test # this is needed for production, otherwise the translations hash below will be empty and uninitialized
    @days = I18n.backend.send(:translations)[I18n.locale][:date][:day_names].rotate
    @weekday = params[:weekday].to_i if params[:weekday] and not params[:weekday].empty?
    @item_article_ids = Item.connection.execute("SELECT article_id from items where created_at between '#{ @from.strftime("%Y-%m-%d") } 00:00:00' AND '#{ @to.strftime("%Y-%m-%d") } 23:59:59' AND hidden IS NULL AND quantity_id IS NULL").to_a.flatten.uniq
    @item_quantity_ids = Item.connection.execute("SELECT quantity_id from items where created_at between '#{ @from.strftime("%Y-%m-%d") } 00:00:00' AND '#{ @to.strftime("%Y-%m-%d") } 23:59:59' AND hidden IS NULL").to_a.flatten.uniq
    
    if params[:print] == '1'
      template = File.read("#{Rails.root}/app/views/statistics/print.txt.erb")
      erb = ERB.new(template, 0, '>')
      text = erb.result(binding)
      
      vendor_printer = @current_vendor.vendor_printers.existing.first
      print_engine = Escper::Printer.new(@current_company.mode, vendor_printer, @current_company.identifier)
      print_engine.open
      print_engine.print(vendor_printer.id, text)
      print_engine.close
    end
  end
end
