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
    params[:type] = "" unless @current_user.role.permissions.include?(params[:type])
    @from, @to = assign_from_to(params)
    
    #settlements for scoping, currently not used
    @settlements = Settlement.where(:created_at => @from..@to, :finished => true).existing
    @sids = @settlements.collect{ |s| s.id }
    
    #taxes
    @taxes = @current_vendor.taxes.existing
    
    #payment methods
    @payment_methods = @current_vendor.payment_methods.existing
    
    #cost centers
    @cost_centers = @current_vendor.cost_centers.existing
    cost_center_ids = @cost_centers.collect{ |cc| cc.id }
    @selected_cost_center = @current_vendor.cost_centers.existing.find_by_id(params[:cost_center_id]) if params[:cost_center_id] and not params[:cost_center_id].empty?
    @csids = @selected_cost_center ? @selected_cost_center.id : ([cost_center_ids] + [nil]).flatten
    
    #users
    @users = @current_vendor.users.existing
    user_ids = @users.collect{ |u| u.id } << nil
    @selected_user = @current_vendor.users.existing.find_by_id(params[:user_id]) if params[:user_id] and not params[:user_id].empty?
    @uids = @selected_user ? @selected_user.id : user_ids
    
    #tables
    @tables = @current_vendor.tables.existing.active
    
    #categories
    @categories = @current_vendor.categories.existing
    
    #statistic categories
    @statistic_categories = @current_vendor.statistic_categories.existing
    
    #days
    test = I18n.t :test # this is needed for production, otherwise the translations hash below will be empty and uninitialized
    daynames = I18n.backend.send(:translations)[I18n.locale][:date][:day_names]
    @days = daynames.rotate if daynames
    @weekday = params[:weekday].to_i if params[:weekday] and not params[:weekday].empty?

    #sales quantities
    @item_article_ids = Item.connection.execute("SELECT article_id FROM items WHERE vendor_id = #{ @current_vendor.id } AND created_at BETWEEN '#{ @from.strftime("%Y-%m-%d %H:%M:%S") }' AND '#{ @to.strftime("%Y-%m-%d %H:%M:%S") }' AND hidden IS NULL AND quantity_id IS NULL").to_a.flatten.uniq
    @item_quantity_ids = Item.connection.execute("SELECT quantity_id FROM items WHERE vendor_id = #{ @current_vendor.id } AND created_at BETWEEN '#{ @from.strftime("%Y-%m-%d %H:%M:%S") }' AND '#{ @to.strftime("%Y-%m-%d %H:%M:%S") }' AND hidden IS NULL").to_a.flatten.uniq
    @articles = Article.where(:id => @item_article_ids).order(:name)
    @quantities = Quantity.where(:id => @item_quantity_ids).order(:article_name)
    
    
    #permitted statistics
    permitted_statistics = @current_user.role.permissions.select{ |p| p =~ /^statistics_.*/ }
    @permitted_statistics_for_select = permitted_statistics.collect do |ps|
      [I18n.t("roles.new.statistics.#{ ps }"), ps]
    end
    
    
    if params[:print] == 'true'
      @friendly_unit = I18n.t('number.currency.format.friendly_unit', :locale => @region)
      
      text = ''
      text += render_statistics_escpos('header')
      text += render_statistics_escpos(params[:statistics_type])
      text += render_statistics_escpos('footer')
      
      vendor_printer = @current_vendor.vendor_printers.existing.first
      print_engine = Escper::Printer.new(@current_company.mode, vendor_printer, File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, @current_vendor.hash_id))
      print_engine.open
      bytes_written, content_sent = print_engine.print(vendor_printer.id, text)
      print_engine.close
      
      # Push notification
      if SalorHospitality.tailor
        printerstring = sprintf("%04i", vendor_printer.id)
        begin
          SalorHospitality.tailor.puts "PRINTEVENT|#{self.vendor.hash_id}|printer#{printerstring}"
        rescue Exception => e
          ActiveRecord::Base.logger.info "[TAILOR] Exception #{ e } during printing."
        end
      end
      
      r = Receipt.new
      r.vendor_id = @current_vendor.id
      r.company_id = @current_company.id
      r.user_id = @current_user.id
      r.content = text
      r.vendor_printer_id = vendor_printer.id
      r.bytes_written = bytes_written
      r.bytes_sent = content_sent.length
      r.save
    end
  end
  
  private
  
  def render_statistics_escpos(template)
    filename = "#{Rails.root}/app/views/statistics/_print_#{ template }.txt.erb"
    if File.exists?(filename)
      template = File.read(filename)
      erb = ERB.new(template, 0, '>')
      return erb.result(binding)
    else
      return "Printing of this statistic type is not implemented yet.\n\n\n\n\n"
    end
  end
end
