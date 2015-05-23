# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class SurchargeItem < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :surcharge
  belongs_to :booking_item
  belongs_to :booking
  belongs_to :season
  has_many :tax_items

  serialize :taxes

  def calculate_totals
    self.duration = self.booking_item.duration
    self.count = self.booking_item.count
    self.from_date = self.booking_item.from_date
    self.to_date = self.booking_item.to_date
    self.sum = self.amount * self.count * self.duration
    self.calculate_taxes(self.surcharge.tax_amounts)
    self.save
  end
  
  def calculate_taxes(tax_array)
    self.tax_items.update_all :hidden => true, :hidden_by => self.hidden_by
    self.taxes = {}
    tax_sum_total = 0
    tax_array.each do |ta|
      tax_object = ta.tax
      if self.vendor.country == 'us'
        net = (self.sum).round(3)
        gro = (net * ( 1.0 + (tax_object.percent / 100.0))).round(3)
      else
        gro = (self.sum).round(3)
        net = (gro / ( 1.0 + ( tax_object.percent / 100.0 ))).round(3)
      end
      tax_sum = (gro - net).round(3)
      self.taxes[tax_object.id] = {:p => tax_object.percent, :t => tax_sum, :g => gro, :n => net, :l => tax_object.letter, :e => tax_object.name }
      
      # TaxItem creation
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :surcharge_item_id => self.id, :booking_item_id => self.booking_item.id, :tax_id => tax_object.id, :booking_id => self.booking_item.booking_id).first
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax_object.letter, :name => tax_object.name, :percent => tax_object.percent, :hidden => nil, :hidden_by => nil
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :surcharge_item_id => self.id, :tax_id => tax_object.id, :booking_id => self.booking_item.booking_id, :booking_item_id => self.booking_item.id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax_object.letter, :name => tax_object.name, :percent => tax_object.percent
      end
      tax_sum_total += tax_sum
    end
    self.tax_sum = tax_sum_total
    self.save
  end
  
  def hide(user_id)
    self.tax_items.existing.update_all :hidden => true, :hidden_by => user_id
    self.hidden = true
    self.hidden_by = user_id
    self.save
  end
  
  def check
    unless !self.hidden_by.nil? and self.hidden_by.zero?
      # If the user clicks "X" to delete a BookingItem, hidden_by is the user_id. If the user simply deselects a SurchargeItem, hidden_by is set to 0 (system). If the BookingItem is deleted, all SurchargeItems must be deleted too.
      test1 = self.hidden == self.booking_item.hidden
      raise "SurchargeItem test1 failed for id #{ self.id }" unless test1
      
      test2 = self.hidden_by == self.booking_item.hidden_by
      raise "SurchargeItem test2 failed for id #{ self.id }" unless test2
    end
    
    unless self.hidden
      test3 = self.count == self.booking_item.count
      raise "SurchargeItem test3 failed for id #{ self.id }" unless test3
    end
    
    test4 = self.sum == self.amount * self.count * self.duration
    raise "SurchargeItem test4 failed for id #{ self.id }" unless test4
    
    if self.hidden
      test5 = self.tax_items.all?{|ti| ti.hidden }
      raise "SurchargeItem test5 failed for id #{ self.id }" unless test5
    end
    
    item_hash_tax = 0
    self.taxes.each do |k,v|
      item_hash_tax += v[:t]
    end
    
    test6 = self.tax_items.sum(:tax).round(2) == item_hash_tax.round(2)
    raise "SurchargeItem test6 failed for id #{ self.id }" unless test6
    
    test7 = self.tax_sum.round(2) == item_hash_tax.round(2)
    raise "SurchargeItem test7 failed for id #{ self.id }" unless test7
    
    test8 = self.tax_items.count == self.taxes.keys.count
    raise "SurchargeItem test8 failed for id #{ self.id }" unless test8
    return true
  end
end
