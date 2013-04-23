# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Settlement < ActiveRecord::Base
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
    printr = Escper::Printer.new(self.company.mode, vendor_printer, self.company.identifier)
    printr.open
    bytes_written, content_sent = printr.print vendor_printer.id, self.escpos
    bytes_sent = content_sent.length
    Receipt.create(:vendor_id => self.vendor_id, :company_id => self.company_id, :user_id => self.user_id, :vendor_printer_id => vendor_printer.id, :settlement_id => self.id, :settlement_nr => self.nr, :content => self.escpos, :bytes_sent => bytes_sent, :bytes_written => bytes_written)
    printr.close
  end

  def escpos
    vendor = self.vendor
    permissions = self.user.role.permissions
    
    friendly_unit = I18n.t('number.currency.format.friendly_unit', :locale => SalorHospitality::Application::COUNTRIES_REGIONS[vendor.country])
    
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
    self.orders.existing.each do |o|
      t = I18n.l(o.created_at, :format => :time_short)
      costcentername = o.cost_center.name if o.cost_center
      nr = o.nr ? o.nr : 0 # failsafe
      list_of_orders += "\n#%07i %7.7s %10.10s  %5.5s  %6.2f" % [nr, o.table.name, costcentername, t, o.sum]
    end
    
    list_of_payment_methods = ''
    list_of_payment_methods_refund = ''
    if permissions.include?('manage_payment_methods')
      payment_methods_hash.each do |hash|
        unless hash[:sum].zero?
          list_of_payment_methods += "%-27s  %s %9.2f\n" % [hash[:name], friendly_unit, hash[:sum]]
        end
        unless hash[:sum_refund].zero?
          name = I18n.t('refund') + ' ' + hash[:name]
          list_of_payment_methods_refund += "%-27s  %s %9.2f\n" % [name, friendly_unit, hash[:sum_refund]]
        end
      end
      list_of_payment_methods += "\xc4" * 42 + "\n" unless list_of_payment_methods.empty?
      list_of_payment_methods_refund += "\xc4" * 42 + "\n" unless list_of_payment_methods_refund.empty?
    end
    
    list_of_costcenters = ''
    if permissions.include?('manage_cost_centers')
      costcenters_hash.each do |hash|
        list_of_costcenters += "%-27s  %s %9.2f\n" % [hash[:name], friendly_unit, hash[:sum]] unless hash[:sum].zero?
      end
      list_of_costcenters += "\xc4" * 42 + "\n" unless list_of_costcenters.empty?
    end
    
    initial_cash = self.initial_cash ? "%s:  %s %9.2f\n" % [I18n.t('various.begin'), friendly_unit, self.initial_cash] : ''
    revenue = self.revenue ? "%s:  %s %9.2f\n" % [I18n.t('various.end'), friendly_unit, self.revenue] : ''
    revenue += "\xc4" * 42 + "\n" unless revenue.empty?
    
    tax_attribute = vendor.country == 'us' ? :net : :gro

    list_of_taxes = ''
    if permissions.include?('settlement_statistics_taxes')
      self.vendor.taxes.existing.where(:include_in_statistics => true, :statistics_by_category => false).each do |tax|
        sum = self.tax_items.where(:tax_id => tax.id).sum(tax_attribute)
        list_of_taxes += "%-27s  %s %9.2f\n" % [tax.name, friendly_unit, sum]
      end
      list_of_taxes += "\xc4" * 42 + "\n" unless list_of_taxes.empty? #permissions.include?('settlement_statistics_taxes_categories')
    end
    
    list_of_taxes_categories = ''
    if permissions.include?('settlement_statistics_taxes_categories')
      self.vendor.taxes.existing.where(:include_in_statistics => true, :statistics_by_category => true).each do |tax|
        list_of_taxes_categories += "%s:\n" % [tax.name]
        if permissions.include?('manage_statistic_categories')
          self.vendor.statistic_categories.existing.each do |cat|
            sum = self.tax_items.existing.where(:refunded => nil, :tax_id => tax.id, :statistic_category_id => cat.id).sum(tax_attribute)
            list_of_taxes_categories += " %-27s %s %9.2f\n" % [cat.name, friendly_unit, sum] unless sum.zero?
          end
        else
          self.vendor.categories.existing.each do |cat|
            sum = self.tax_items.existing.where(:tax_id => tax.id, :category_id => cat.id, :refunded => nil).sum(tax_attribute)
            list_of_taxes_categories += " %-27s %s %9.2f\n" % [cat.name, friendly_unit, sum] unless sum.zero?
          end
        end

      end
      list_of_taxes_categories += "\xc4" * 42 + "\n" unless list_of_taxes_categories.empty?
    end
    
    list_of_sold_quantities = ''
    if permissions.include?('settlement_statistics_sold_quantities')
      item_article_ids = Item.connection.execute("SELECT article_id FROM items WHERE settlement_id = #{ self.id } AND hidden IS NULL AND quantity_id IS NULL").to_a.flatten.uniq
      item_quantity_ids = Item.connection.execute("SELECT quantity_id FROM items WHERE settlement_id = #{ self.id } AND hidden IS NULL").to_a.flatten.uniq
    end
    

    output =
    "\e@"     +  # Initialize Printer
    "\ea\x00" +  # align left
    "\e!\x38" +  # doube tall, double wide, bold
    "#{ I18n.t('activerecord.models.settlement.one') } ##{ self.nr }\n#{ self.user.login }\n\n"    +
    "\e!\x00" +  # Font A
    "%-10.10s %s\n" % [I18n.t('various.begin'), I18n.l(self.created_at, :format => :datetime_iso)] +
    "%-10.10s %s\n" % [I18n.t('various.end'), I18n.l(self.updated_at, :format => :datetime_iso)] +
    "\n#%7.7s %7.7s  %10.10s %5.5s  %5.5s\n" % [Order.human_attribute_name(:nr), I18n.t('activerecord.models.table.one'), I18n.t('activerecord.models.cost_center.one'), I18n.t('various.time'),  I18n.t(:sum)]+
    list_of_orders +
    "\n" +
    "\e!\x18" +  # double tall, bold
    "%-27s  %s %9.2f\n" % [I18n.t(:sum), friendly_unit, self.sum] +
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
      errors = self.check.flatten
      if errors.any?
        UserMailer.technician_message(self.vendor, "Errors in Settlement #{ self.nr }", errors.to_s).deliver
      end
    end
  end
  
  def check
    messages = []
    tests = []
    
    self.orders.each do |o|
      messages << o.check
    end
    
    tests[1] = self.sum.round(2) == self.orders.existing.sum(:sum).round(2)
    
    tests[2] = self.payment_method_items.existing.where(:order_id => nil).any? == false
    
    0.upto(tests.size-1).each do |i|
      messages << "Settlement #{ self.id }: test#{i} failed." if tests[i] == false
    end
    return messages
  end

end
