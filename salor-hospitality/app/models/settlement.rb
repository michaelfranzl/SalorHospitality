# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Settlement < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include Scope
  belongs_to :company
  belongs_to :vendor
  belongs_to :user
  has_many :receipts
  has_many :orders
  has_many :items
  has_many :tax_items
  has_many :payment_method_items

  def finish
    orders = Order.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil, :user_id => self.user_id, :finished => true)
    
    order_ids = orders.collect {|o| o.id}
    
    orders.update_all(:settlement_id => self.id)
    
    Item.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil, :order_id => order_ids).update_all(:settlement_id => self.id)
    
    TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil, :order_id => order_ids).update_all(:settlement_id => self.id)
    
    PaymentMethodItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil, :order_id => order_ids).update_all(:settlement_id => self.id)
    
    self.finished = true
    self.calculate_totals
  end
  
  def calculate_totals
    self.sum = Order.existing.where(:settlement_id => self.id).sum(:sum).round(2)
    self.save
  end

  def revenue=(revenue)
    write_attribute(:revenue, revenue.gsub(',', '.'))
  end

  def initial_cash=(initial_cash)
    write_attribute(:initial_cash, initial_cash.gsub(',', '.'))
  end

  def print
    vendor_printer = self.vendor.vendor_printers.existing.first
    return if vendor_printer.nil?
    
    output = self.escpos
    
    printr = Escper::Printer.new(self.company.mode, vendor_printer, File.join(SalorHospitality::Application::SH_DEBIAN_SITEID, self.vendor.hash_id))
    printr.open
    bytes_written, content_sent = printr.print vendor_printer.id, output
    printr.close
    
    # Push notification
    if SalorHospitality.tailor
      printerstring = sprintf("%04i", vendor_printer.id)
      begin
        SalorHospitality.tailor.puts "PRINTEVENT|#{self.vendor.hash_id}|printer#{printerstring}"
      rescue Exception => e
        ActiveRecord::Base.logger.info "[TAILOR] Exception #{ e } during printing."
      end
    end
    
    bytes_sent = content_sent.length
    
    if SalorHospitality::Application::CONFIGURATION[:receipt_history] == true
      Receipt.create :vendor_id => self.vendor_id,
          :company_id => self.company_id,
          :user_id => self.user_id,
          :vendor_printer_id => vendor_printer.id,
          :settlement_id => self.id,
          :settlement_nr => self.nr,
          :content => self.escpos,
          :bytes_sent => bytes_sent,
          :bytes_written => bytes_written
    end
  end

  def escpos
    vendor = self.vendor
    
    order_format = "\n%7i %6.6s %10.10s %5.5s %10.10s"
    header_format = "%7.7s|%6.6s|%10.10s|%5.5s|%10.10s\n"
    sum_format = "%-27s %s %10.10s\n"
    
    permissions = self.user.role.permissions
    friendly_unit = I18n.t('number.currency.format.friendly_unit', :locale => vendor.region)
    
    costcenter_ids = self.vendor.cost_centers.existing.collect{ |cc| cc.id }
    costcenter_ids << nil
    costcenters_hash = costcenter_ids.collect do |ccid|
      sum = self.items.existing.where(:cost_center_id => ccid, :refunded => nil).sum(:sum)
      cost_center = self.vendor.cost_centers.find_by_id(ccid)
      if cost_center
        returnvalue = {:name => cost_center.name, :sum => sum}
      else
        returnvalue = {:name => '', :sum => sum}
      end
    end

    payment_method_ids = self.vendor.payment_methods.existing.collect{ |pm| pm.id }
    payment_methods_hash = payment_method_ids.collect do |pmid|
      payment_method = self.vendor.payment_methods.existing.find_by_id(pmid)
      next if payment_method.change
      if payment_method.cash
        sum_refund = self.payment_method_items.existing.where(:payment_method_id => pmid, :refunded => true).sum(:amount)
        sum = self.payment_method_items.existing.where(:payment_method_id => pmid, :refunded => nil, :change => false).sum(:amount) - self.payment_method_items.existing.where(:refunded => nil, :change => true).sum(:amount) - sum_refund
      else
        sum_refund = self.payment_method_items.existing.where(:payment_method_id => pmid, :refunded => true).sum(:amount)
        sum = self.payment_method_items.existing.where(:payment_method_id => pmid, :refunded => nil).sum(:amount) - sum_refund
      end
      name = payment_method.name
      returnvalue = {:name => name, :sum => sum, :sum_refund => sum_refund}
    end
    payment_methods_hash.delete(nil)
    
    list_of_orders = ''
    self.orders.existing.where(:finished => true).each do |o|
      t = I18n.l(o.finished_at, :format => :time_short)
      costcentername = o.cost_center.name if o.cost_center
      nr = o.nr ? o.nr : 0 # failsafe
      order_values = [
        nr,
        o.table.name,
        costcentername,
        t,
        number_with_precision(o.sum, :locale => vendor.region)
      ]
      list_of_orders += order_format % order_values
    end
    
    list_of_payment_methods = ''
    list_of_payment_methods_refund = ''
    if permissions.include?('manage_payment_methods')
      payment_methods_hash.each do |hash|
        unless hash[:sum].zero?
          payment_method_values = [
            hash[:name],
            friendly_unit,
            number_with_precision(hash[:sum], :locale => vendor.region)
          ]
          list_of_payment_methods += sum_format % payment_method_values
        end
        unless hash[:sum_refund].zero?
          name = I18n.t('refund') + ' ' + hash[:name]
          payment_method_refund_values = [
            name,
            friendly_unit,
            number_with_precision(hash[:sum_refund], :locale => vendor.region)
          ]
          list_of_payment_methods_refund += sum_format % payment_method_refund_values
        end
      end
      list_of_payment_methods += "\xc4" * 42 + "\n" unless list_of_payment_methods.empty?
      list_of_payment_methods_refund += "\xc4" * 42 + "\n" unless list_of_payment_methods_refund.empty?
    end
    
    list_of_costcenters = ''
    if permissions.include?('manage_cost_centers')
      costcenters_hash.each do |hash|
        cost_center_values = [
          hash[:name],
          friendly_unit,
          number_with_precision(hash[:sum], :locale => vendor.region)
        ]
        list_of_costcenters += sum_format % cost_center_values unless hash[:sum].zero?
      end
      list_of_costcenters += "\xc4" * 42 + "\n" unless list_of_costcenters.empty?
    end
    
    if self.initial_cash
      initial_cash_values = [
        I18n.t('various.begin'),
        friendly_unit,
        number_with_precision(self.initial_cash, :locale => vendor.region)
      ]
      initial_cash = sum_format % initial_cash_values
    else
      initial_cash = ''
    end
    
    if self.revenue
      revenue_values = [
        I18n.t('various.end'),
        friendly_unit,
        number_with_precision(self.revenue, :locale => vendor.region)
      ]
      revenue = sum_format % revenue_values
      revenue += "\xc4" * 42 + "\n"
    else
      revenue = ''
    end
    
    
    tax_attribute = vendor.country == 'us' ? :net : :gro

    list_of_taxes = ''
    if permissions.include?('settlement_statistics_taxes')
      self.vendor.taxes.existing.where(:include_in_statistics => true, :statistics_by_category => false).each do |tax|
        sum = self.tax_items.existing.where(:tax_id => tax.id, :refunded => nil).sum(tax_attribute)
        tax_values = [
          tax.name,
          friendly_unit,
          number_with_precision(sum, :locale => vendor.region)
        ]
        list_of_taxes += sum_format % tax_values
      end
      list_of_taxes += "\xc4" * 42 + "\n" unless list_of_taxes.empty?
    end
    
    list_of_taxes_categories = ''
    if permissions.include?('settlement_statistics_taxes_categories')
      self.vendor.taxes.existing.where(:include_in_statistics => true, :statistics_by_category => true).each do |tax|
        list_of_taxes_categories += "%s:\n" % [tax.name]
        if permissions.include?('manage_statistic_categories')
          self.vendor.statistic_categories.existing.each do |cat|
            sum = self.tax_items.existing.where(:refunded => nil, :tax_id => tax.id, :statistic_category_id => cat.id).sum(tax_attribute)
            taxes_categories_values = [
              cat.name,
              friendly_unit,
              number_with_precision(sum, :locale => vendor.region)
            ]
            list_of_taxes_categories += " " + sum_format % taxes_categories_values unless sum.zero?
          end
        else
          self.vendor.categories.existing.each do |cat|
            sum = self.tax_items.existing.where(:tax_id => tax.id, :category_id => cat.id, :refunded => nil).sum(tax_attribute)
            list_of_categories_values = [
              cat.name,
              friendly_unit,
              number_with_precision(sum, :locale => vendor.region)
            ]
            list_of_taxes_categories += " " + sum_format % list_of_categories_values unless sum.zero?
          end
        end

      end
      list_of_taxes_categories += "\xc4" * 42 + "\n" unless list_of_taxes_categories.empty?
    end
    
    sum_values = [
      I18n.t(:sum),
      friendly_unit,
      number_with_precision(self.sum, :locale => vendor.region)
    ]
    sum_string = sum_format % sum_values

    output =
    "\e@"     +  # Initialize Printer
    self.vendor.name.to_s +
    "\n" + 
    self.vendor.receipt_header_blurb.to_s + 
    "\n" +
    "\ea\x00" +  # align left
    "\e!\x38" +  # doube tall, double wide, bold
    "#{ I18n.t('activerecord.models.settlement.one') } ##{ self.nr }\n#{ self.user.login }\n\n"    +
    "\e!\x00" +  # Font A
    "%-15.15s: %s\n" % [I18n.t('various.begin'), I18n.l(self.created_at + self.vendor.time_offset.hours, :format => :datetime_iso)] +
    "%-15.15s: %s\n" % [I18n.t('various.end'), I18n.l(self.updated_at + self.vendor.time_offset.hours, :format => :datetime_iso)] +
    "%-15.15s: %i\n" % [I18n.t('activerecord.models.order.other'), self.orders.existing.where(:finished => true).count] +
    "%-15.15s: %i\n" % [I18n.t('activerecord.models.article.other'), self.items.existing.count] +
    "\n" +
    header_format % [Order.human_attribute_name(:nr), I18n.t('activerecord.models.table.one'), I18n.t('activerecord.models.cost_center.one'), I18n.t('various.time'),  I18n.t(:sum)] +
    "\xc4" * 42 +
    list_of_orders +
    "\n" +
    "\e!\x18" +  # double tall, bold
    sum_string +
    "\xc4" * 42 + "\n" +
    list_of_costcenters +
    list_of_payment_methods +
    list_of_payment_methods_refund +
    list_of_taxes +
    list_of_taxes_categories +
    initial_cash +
    revenue +
    "\e!\x01" + # Font A
    "\n\n\n\n\n" +
    "\x1DV\x00" # paper cut
  end
  
  def report_errors_to_technician
    if self.vendor.enable_technician_emails == true and self.vendor.technician_email
      report_string = ""
      
      begin
      report, found = self.check
        PP.pp report, report_string
      rescue Exception => e
        report_string = "Error during call to Settlement.check\n\n#{ e.message  }\n\n#{ e.backtrace.inspect }"
        UserMailer.technician_message(self.vendor, "Exception in Settlement #{ self.nr }", report_string).deliver
      end
      
      if found
        UserMailer.technician_message(self.vendor, "Problems in Settlement #{ self.nr }", report_string).deliver
      end
    end
  end
  
  def check
    @found = nil
    @tests = {
      self.id => {
                      :tests => [],
                      :orders => [],
                     }
    }
    
    self.orders.existing.each do |o|
      order_result, @found = o.check
      @tests[self.id][:orders] << order_result if @found
    end
    
    perform_test({
              :should => self.orders.existing.sum(:sum).round(2),
              :actual => self.sum,
              :msg => "The cached sum attribute should match order sums",
              :type => :settlementSumMatchesOrderSums,
              })
    
    return @tests, @found
  end
  
private
  
  def perform_test(options)
    should = options[:should]
    actual = options[:actual]
    pass = should == actual
    type = options[:type]
    msg = options[:msg]
    @tests[self.id][:tests] << {
      :type => type,
      :msg => msg,
      :should => should,
      :actual => actual
    } if pass == false
    @found = true if pass == false
  end

end
