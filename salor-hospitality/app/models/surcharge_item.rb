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
    
    if self.hidden
      self.sum = 0
    else
      self.sum = self.amount * self.count * self.duration
      self.calculate_taxes(self.surcharge.tax_amounts)
    end
    self.save
  end
  
  def calculate_taxes(tax_array)
    self.taxes = {}
    tax_array.each do |ta|
      tax_object = ta.tax
      tax_sum = (ta.amount * ( tax_object.percent / 100.0 )).round(2) * self.count * self.duration
      gro = (ta.amount).round(2) * self.count * self.duration
      net = (gro - tax_sum).round(2)
      self.taxes[tax_object.id] = {:p => tax_object.percent, :t => tax_sum, :g => gro, :n => net, :l => tax_object.letter, :e => tax_object.name }
      
      # TaxItem creation
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :surcharge_item_id => self.id, :booking_item_id => self.booking_item.id, :tax_id => tax_object.id, :booking_id => self.booking_item.booking_id).first
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax_object.letter, :name => tax_object.name, :percent => tax_object.percent
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :surcharge_item_id => self.id, :tax_id => tax_object.id, :booking_id => self.booking_item.booking_id, :booking_item_id => self.booking_item.id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax_object.letter, :name => tax_object.name, :percent => tax_object.percent
      end
    end
    self.save
  end
end
