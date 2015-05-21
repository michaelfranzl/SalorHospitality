# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PaymentMethod < ActiveRecord::Base
  #attr_accessible :amount, :name, :order_id, :cash, :change
  include Scope
  belongs_to :order
  belongs_to :vendor
  belongs_to :company
  
  validates_presence_of :name
  #validates_uniqueness_of :cash, :scope => :vendor_id
  #validates_uniqueness_of :change, :scope => :vendor_id

  def amount=(amnt)
    write_attribute :amount,amnt.to_s.gsub(',','.')
  end
  
  def refund_name
    I18n.t(:refund) + ': ' + self.name
  end
  
  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.hidden_at = Time.now
    self.save
  end
end
