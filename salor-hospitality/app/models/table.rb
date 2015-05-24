# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Table < ActiveRecord::Base
  include Scope
  has_many :orders
  has_many :histories, :as => 'model'
  belongs_to :user
  belongs_to :company
  belongs_to :vendor
  belongs_to :customer
  belongs_to :user, :class_name => 'User', :foreign_key => 'active_user_id'
  belongs_to :active_customer, :class_name => 'Customer', :foreign_key => 'active_customer_id'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :vendor_id
  has_and_belongs_to_many :users
  
  def update_color
    orders = self.vendor.orders.existing.where(:finished => false, :table_id => self.id)
    lastorder = orders.last
    if lastorder.nil?
      self.active_user_id = nil
      self.active_customer_id = nil
      self.note = nil
      self.save
    else
      self.active_user_id = lastorder.user_id
      self.active_customer_id = lastorder.customer_id
      self.note = lastorder.note
      self.save
    end
  end
  
  def move_name
    name = self.active_user_id ? '☒' : '☐'
    name += self.name
    return name
  end
  
  def set_request_finish
    self.request_finish = true
    self.save
  end
  
  def set_request_waiter
    self.request_waiter = true
    self.save
  end
  
  def hide(by_user_id)
    self.name = "DEL#{(rand(99999) + 10000).to_s[0..4]}#{self.name}"
    self.hidden = true
    self.hidden_by = by_user_id
    self.hidden_at = Time.now
    self.save
  end
end
