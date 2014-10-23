# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class TaxItem < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :item
  belongs_to :booking_item
  belongs_to :surcharge_item
  belongs_to :order
  belongs_to :booking
  belongs_to :settlement
  belongs_to :user
  belongs_to :taxobject, :class_name => "Tax", :foreign_key => "tax_id"
  
  def hide(by_user)
    self.hidden = true
    self.hidden_by = by_user
    self.hidden_at = Time.now
    self.save
  end
  
  def check
    @found = nil
    @tests = {
      self.id => {
                    :tests => [],
                    }
    }
                     
    
    perform_test({
              :should => [self.item.hidden, self.item.hidden_by, self.item.hidden_at],
              :actual => [self.hidden, self.hidden_by, self.hidden_at],
              :msg => "A TaxItem should have the same hidden attributes as the Item",
              :type => :taxItemSameHiddenAttributes,
              })
    
    perform_test({
              :should => [self.item.order_id, self.item.cost_center_id, self.item.settlement_id, self.user_id],
              :actual => [self.order_id, self.cost_center_id, self.settlement_id, self.user_id],
              :msg => "A TaxItem should have the same belongs_to attributes as the Item",
              :type => :taxItemSameBelongsToAttributes,
              })
    
    perform_test({
              :should => self.item.refunded,
              :actual => self.refunded,
              :msg => "A TaxItem should have the same refunded attribute as the Item",
              :type => :taxItemSameRefundedAttribute,
              })
    
    if self.vendor.country == 'us'
      perform_test({
                :should => self.item.sum,
                :actual => self.net,
                :msg => "The net amount of the TaxItem should be correct",
                :type => :taxItemNetCorrect,
                })
      
      perform_test({
                :should => (self.item.sum * ( 1.0 + (self.taxobject.percent / 100.0))).round(2),
                :actual => self.gro,
                :msg => "The gross amount of the TaxItem should be correct",
                :type => :taxItemGrossCorrect,
                })
    else
      perform_test({
                :should => (self.item.sum / ( 1.0 + ( self.taxobject.percent / 100.0 ))).round(2),
                :actual => self.net,
                :msg => "The net amount of the TaxItem should be correct",
                :type => :taxItemNetCorrect,
                })
      
      perform_test({
                :should => self.item.sum,
                :actual => self.gro,
                :msg => "The gross amount of the TaxItem should be correct",
                :type => :taxItemGrossCorrect,
                })
    end
    
    perform_test({
              :should => (self.gro - self.net).round(2),
              :actual => self.tax,
              :msg => "The tax amount of the TaxItem should be the difference between gro and net",
              :type => :taxItemTaxShouldGroMinusNet,
              })
    
    perform_test({
              :should => self.item.tax_sum,
              :actual => self.tax,
              :msg => "The tax amount of the TaxItem should match tax_sum of the Ite",
              :type => :taxItemTaxShouldMatchItem,
              })
    
    puts "\n *** WARNING: TaxItem is deleted, tests are irrelevant! *** \n" if self.hidden
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
