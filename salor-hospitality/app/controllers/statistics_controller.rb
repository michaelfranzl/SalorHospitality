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
    
    #permitted statistics
    permitted_statistics = @current_user.role.permissions.select{ |p| p =~ /^statistics_.*/ }
    @permitted_statistics_for_select = permitted_statistics.collect do |ps|
      [I18n.t("roles.new.statistics.#{ ps }"), ps]
    end
    
    @from, @to = assign_from_to(params)
    
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
    @daynames = daynames.rotate if daynames
    #@weekday = params[:weekday].to_i if params[:weekday] and not params[:weekday].empty?
    

    @current_vendor.public_holidays = params[:public_holidays] if params[:public_holidays]
    @current_vendor.save
    if @current_vendor.errors.any?
      # this will show a warning message in the view
      flash[:public_holidays_error] = true
      @public_holidays = params[:public_holidays]
      return
    end
    @public_holidays = @current_vendor.public_holidays
    @public_holidays ||= "#{ Time.now.year }-12-25\n#{ Time.now.year }-12-26" # example for users
    
    @settlements = @current_vendor.settlements.existing.where(
      :created_at => @from..@to,
      :finished => true
    )
    @sids = @settlements.collect{ |s| s.id }
    
    if params[:statistics_type] == "statistics_weekday" and @current_vendor.public_holidays_array
      @sids_public_holidays = []
      @current_vendor.public_holidays_array.each do |holiday_date|
        holiday_from = Date.parse(holiday_date).beginning_of_day
        holiday_to = Date.parse(holiday_date).end_of_day
        next if holiday_from < @from or holiday_from > @to # ignore holidays which are outside of the selected time window
        settlements = @current_vendor.settlements.existing.where(
          :created_at => holiday_from..holiday_to,
          :finished => true
        )
        settlement_ids = settlements.collect{ |s| s.id }
        @sids_public_holidays += settlement_ids
      end
      @sids -= @sids_public_holidays
    end

    # data gathering for sales quantities
    if params[:statistics_type] == "statistics_sold_quantities"
      @item_article_ids = @current_vendor.items.existing.where(:settlement_id => @sids).collect{|i| i.article_id}.sort.uniq
      @item_quantity_ids = @current_vendor.items.existing.where(:settlement_id => @sids).collect{|i| i.quantity_id}
      @item_quantity_ids.delete(nil)
      @item_quantity_ids.sort!
      @item_quantity_ids.uniq!
      
      @articles = Article.where(:id => @item_article_ids).order(:name)
      @quantities = Quantity.joins(:article).where(:id => @item_quantity_ids).order("articles.tax_id ASC")
      @data = {}
      @articles.each do |a|
        next if not params[:filter_tax_id].blank? and a.taxes.first.id != params[:filter_tax_id].to_i
        items = @current_vendor.items.existing.where(
          :refunded => nil,
          :article_id => a.id,
          :quantity_id => nil,
          :settlement_id => @sids,
          :user_id => @uids,
          :cost_center_id => @csids
        )
        @data["article_#{ a.id }"] = {
          :article_name => a.name,
          :quantity_name => "",
          :full_name => a.name,
          :tax => a.taxes.first.name,
          :tax_letter => a.taxes.first.letter,
          :category => a.category.name,
          :count => items.sum(:count).round(2),
          :sum => items.sum(:sum).round(2)
        }
      end
      
      @quantities.each do |q|
        a = q.article
        next if not params[:filter_tax_id].blank? and a.taxes.first.id != params[:filter_tax_id].to_i
        items = @current_vendor.items.existing.where(
          :refunded => nil,
          :quantity_id => q.id,
          :settlement_id => @sids,
          :user_id => @uids,
          :cost_center_id => @csids
        )
        @data["quantity_#{ q.id }"] = {
          :article_name => a.name,
          :quantity_name => "#{ q.prefix } #{ q.postfix }",
          :full_name => "#{ q.prefix } #{ a.name } #{ q.postfix }",
          :tax => a.taxes.first.name,
          :tax_letter => a.taxes.first.letter,
          :category => a.category.name,
          :count => items.sum(:count).round(2),
          :sum => items.sum(:sum).round(2)
        }
      end
      params[:sortby] ||= "article_name"
      @data = @data.sort_by do |id, data|
        data[params[:sortby].to_sym]
      end
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
      
      if SalorHospitality::Application::CONFIGURATION[:receipt_history] == true
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
  end
  
  private
  
  def render_statistics_escpos(template)
    filename = "#{Rails.root}/app/views/statistics/_print_#{ template }.txt.erb"
    if File.exists?(filename)
      template = File.read(filename)
      erb = ERB.new(template, 0, '>')
      return erb.result(binding)
    else
      return "\n\nPrinting of this statistic type (#{ template }) is not implemented yet.\n\n\n\n\n"
    end
  end
end
