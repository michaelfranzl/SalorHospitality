# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Customer < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :orders
  has_many :bookings
  has_one :table
  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_uniqueness_of :email, :scope => :company_id
  validates_presence_of :password
  validate :password_length
  
  def password_length
    if self.password and self.password.length < 6
      errors.add(:password, I18n.t('activerecord.errors.messages.too_short', :count => 6))
    end
  end

  def to_hash(vendor)
#     table_id = nil
#     if self.table_id
#       # if customer has set a dedicated table, "place" him there. this would be used for "anonymous" customers for self-ordering in a restaurant
#       table_id = self.table_id
#     else
#       # if customer does not have a dedicated table set, which is the case for non-anonymous customers when ordering from their own account, use the first free (customer_id == nil) table with has the 'customer == true' attribute set, of the currently logged in vendor.
#       table_id = vendor.tables.existing.where(:customer_table => true, :customer_id => nil).first.id # first empty table
#     end
    return {:id => self.id, :name => self.full_name(true) }
  end

  def full_name(simple = false)
    if simple then
      return "#{ self.last_name },#{ self.first_name }"
    else
      return "#{ self.last_name } #{ self.first_name } #{ self.company_name.empty? ? '' : '(' + self.company_name + ')' }"
    end
  end
end
