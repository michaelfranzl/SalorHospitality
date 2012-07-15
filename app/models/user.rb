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
  has_many :histories
  has_many :bookings
  has_and_belongs_to_many :tables
  validates_presence_of :login, :password, :title

  def tables_array=(ids)
    self.tables = []
    ids.each do |id|
      self.tables << Table.find_by_id(id.to_i)
    end
  end
  
  #def create_salt
  #  self.salt = (0...5).map{ ('a'..'z').to_a[rand(26)] }.join
  #end
  
  #def generate_password(string)
  #  create_salt
  #  return Digest::SHA2.hexdigest("#{self.salt}#{string}")
  #end
  
  #def self.login(email,pass)
  #  user = User.find_by_email(email)
  #  if user then
  #    return user if user.encrypted_password == Digest::SHA2.hexdigest("#{user.salt}#{pass}")
  #  end
  #  return nil
  #end
  
  #def password=(string)
  #  return if string.empty? and not self.encrypted_password.empty?
  #  if string.length < 5 then
  #    self.errors[:base] << "password must be greater than or equal to 5 characters."
  #  end
  #  write_attribute(:encrypted_password, generate_password(string))
  #end
  
  #def password
  #  "ActiveRecord Error: Invalid attribute 'password'."
  #end
end
