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

  serialize :taxes

  def calculate_totals
    puts "XXX SurchargeItem -> calculate_totals"
    self.taxes = {}
    self.surcharge.tax_amounts.each do |ta|
      puts "  XXX loop for tax_amount #{ ta.id }"
      tax_object = ta.tax
      tax_sum = (ta.amount * ( tax_object.percent / 100.0 )).round(2)
      gro = (ta.amount).round(2)
      net = (gro - tax_sum).round(2)
      self.taxes[tax_object.id] = {:p => tax_object.percent, :t => tax_sum, :g => gro, :n => net, :l => tax_object.letter, :e => tax_object.name }
      self.save
    end
    puts "  XXX set self.taxes to #{self.taxes.inspect}"
  end
end
