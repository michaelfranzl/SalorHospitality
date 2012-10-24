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
  has_many :orders
  has_many :items
  has_many :tax_items

  def finish
    Order.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil, :user_id => self.user_id, :finished => true).update_all(:settlement_id => self.id)
    Item.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil).update_all(:settlement_id => self.id)
    TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil).update_all(:settlement_id => self.id)
    PaymentMethodItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :settlement_id => nil).update_all(:settlement_id => self.id)
    self.calculate_totals
  end
  
  def calculate_totals
    self.sum = Order.where(:settlement_id => self.id).sum(:sum).round(2)
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
    printr = Printr.new(vendor_printer)
    printr.open
    printr.print vendor_printer.id, self.escpos
    printr.close
  end

  def calculate_totals
    self.update_attribute :sum, self.orders.sum(:sum)
  end

  def escpos
    friendly_unit = I18n.t('number.currency.format.friendly_unit')
    
    total_payment_methods = {}
    total_payment_methods_refund = {}
    list_of_orders = ''
    self.orders.existing.each do |o|
      t = I18n.l(o.created_at, :format => :time_short)
      nr = o.nr ? o.nr : 0 # failsafe
      list_of_orders += "#%7.7u   %10.10s  %7.7s    %8.2f\n" % [nr, o.table.name, t, o.sum]

      o.payment_method_items.each do |pmi|
        if pmi.refunded
          if total_payment_methods_refund.has_key? pmi.payment_method_id
            total_payment_methods_refund[pmi.payment_method_id][:amount] += pmi.amount
          else
            total_payment_methods_refund[pmi.payment_method_id] = {:amount => pmi.amount, :name => "#{ I18n.t(:refund)} #{pmi.payment_method.name}"}
          end
        else
          if total_payment_methods.has_key? pmi.payment_method_id
            total_payment_methods[pmi.payment_method_id][:amount] += pmi.amount
          else
            total_payment_methods[pmi.payment_method_id] = {:amount => pmi.amount, :name => "#{pmi.payment_method.name}"}
          end
        end
      end
    end
    
    list_of_payment_methods = ''
    total_payment_methods.each do |id,amount|
      list_of_payment_methods += "%s:  #{ friendly_unit } %9.2f\n" % [total_payment_methods[id][:name], total_payment_methods[id][:amount]] unless total_payment_methods[id][:amount].zero?
    end

    list_of_payment_methods_refund = ''
    total_payment_methods_refund.each do |id,amount|
      list_of_payment_methods_refund += "%s:  #{ friendly_unit } %9.2f\n" % [total_payment_methods_refund[id][:name], total_payment_methods_refund[id][:amount]] unless total_payment_methods_refund[id][:amount].zero?
    end
    
    initial_cash = self.initial_cash ? "\n#{ I18n.t 'various.begin' }:  #{ friendly_unit } %9.2f\n" % [self.initial_cash] : ''
    revenue = self.revenue ? "#{ I18n.t 'various.end' }:  #{ friendly_unit } %9.2f\n" % [self.revenue] : ''
    
    output =
    "\e@"     +  # Initialize Printer
    "\ea\x00" +  # align left
    "\e!\x38" +  # doube tall, double wide, bold
    "#{ I18n.t('activerecord.models.settlement.one') } ##{ self.id }\n#{ self.user.login }\n\n"    +
    "\e!\x00" +  # Font A
    "%-10.10s %s\n" % [I18n.t('various.begin'), I18n.l(self.created_at, :format => :datetime_iso)] +
    "%-10.10s %s\n" % [I18n.t('various.end'), I18n.l(self.updated_at, :format => :datetime_iso)] +
    "\n#%7.7s   %10.10s  %7.7s    %8.8s\n" % [Order.human_attribute_name(:nr), I18n.t('activerecord.models.table.one'), I18n.t('various.time'),  I18n.t(:sum)]+
    list_of_orders +
    "                               -----------\n" +
    "\e!\x18" +  # double tall, bold
    "\ea\x02" +  # align right
    "%s:  #{ friendly_unit } %9.2f\n" % [I18n.t(:sum), self.sum] +
    list_of_payment_methods +
    list_of_payment_methods_refund +
    initial_cash +
    revenue +
    "\e!\x01" + # Font A
    "\n\n\n\n\n" +
    "\x1DV\x00" # paper cut

    Printr.sanitize(output)
  end

end
