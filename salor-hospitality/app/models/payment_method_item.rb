# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class PaymentMethodItem < ActiveRecord::Base
  #attr_accessible :amount, :company_id, :payment_method_id, :vendor_id, :order_id, :booking_id, :refunded, :cash, :refund_item_id, :settlement_id, :refunded, :cost_center_id, :change, :user_id
  include Scope
  belongs_to :payment_method
  belongs_to :order
  belongs_to :vendor
  belongs_to :company
  belongs_to :user
  belongs_to :refund_item, :class_name => 'Item', :foreign_key => 'refund_item_id'
  belongs_to :settlement
end
