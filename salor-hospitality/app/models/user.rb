# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class User < ActiveRecord::Base
  include Scope
  has_many :settlements
  has_many :orders
  has_one :cash_drawer
  belongs_to :role
  belongs_to :company
  has_and_belongs_to_many :vendors
  has_many :bookings
  has_many :receipts
  has_and_belongs_to_many :tables
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :title
  validates_presence_of :default_vendor_id
  validates_presence_of :vendors
  validates_uniqueness_of :password, :scope => :company_id unless defined?(ShSaas) == 'constant'

  def tables_array=(ids)
    self.tables = []
    ids.each do |id|
      self.tables << self.company.tables.find_by_id(id.to_i)
    end
  end
  
  def vendors_array=(ids)
    self.vendors = []
    ids.each do |id|
      self.vendors << self.company.vendors.find_by_id(id.to_i)
    end
  end
  
  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    self.hidden_at = Time.now
    self.save
  end
end