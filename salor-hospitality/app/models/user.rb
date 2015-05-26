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
  has_one :cash_drawer
  has_many :settlements
  has_many :orders
  has_many :bookings
  has_many :receipts
  has_many :payment_method_items
  has_many :tax_items
  has_many :histories
  belongs_to :role
  belongs_to :company
  has_and_belongs_to_many :vendors
  has_and_belongs_to_many :tables
  has_many :user_logins
  
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :title
  validates_presence_of :default_vendor_id
  validates_presence_of :role_id
  validates_presence_of :vendors
  validates_uniqueness_of :password, :scope => :company_id unless defined?(ShSaas) == 'constant'

  def tables_array=(ids)
    self.tables = []
    self.save
    tables = []
    ids.each do |id|
      tables << self.company.tables.find_by_id(id.to_i)
    end
    self.tables = tables
    self.save
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
  
  def current_settlement
    self.company.settlements.find_by_id(self.current_settlement_id)
  end
  
  def log_in(vendor, by_user)
    return unless self.track_time == true
    
    last_ul = self.user_logins.last
    if last_ul and last_ul.logout.nil?
      # user has missed to log out properly. We create a logout record now since logins and logouts must be alternating in the database.
      ul = UserLogin.new
      ul.company = self.company
      ul.vendor = vendor
      ul.user = self
      ul.logout = Time.now
      ul.login = nil
      ul.log_by_user_id = by_user.id
      ul.hourly_rate = self.hourly_rate
      ul.save
    end
    
    
    ul = UserLogin.new
    ul.company = self.company
    ul.vendor = vendor
    ul.user = self
    ul.login = Time.now
    ul.logout = nil
    ul.log_by_user_id = by_user.id
    ul.hourly_rate = self.hourly_rate
    ul.save
    
    if self.current_settlement_id.nil?
      # convenience settlement creation during login, for users who forget to start a settlement before midnight
      self.settlement_start(vendor, by_user, '0.0')
    end
  end
  
  def log_out(vendor, by_user, autologout=nil)
    return unless self.track_time == true
    
    ul = UserLogin.new
    ul.company = self.company
    ul.vendor = vendor
    ul.user = self
    ul.login = nil
    ul.logout = Time.now
    ul.auto_logout = autologout
    ul.log_by_user_id = by_user.id
    ul.hourly_rate = self.hourly_rate
    ul.save
  end
  
  def settlement_start(vendor, by_user, initial_cash)
    s = Settlement.new
    s.nr = vendor.get_unique_model_number('settlement')
    s.calculate_totals
    s.vendor = vendor
    s.company = self.company
    s.user = self
    s.start_by_user_id = by_user.id
    s.initial_cash = initial_cash
    result = s.save
    if result == false
      raise "Settlement could not be saved because #{ s.errors.messages }"
    end
    
    self.current_settlement_id = s.id
    result = self.save
    if result != true
      raise "Could not save user because #{ self.errors.messages }"
    end
    return s
  end
  
  def settlement_stop(vendor, by_user, revenue)
    s = vendor.settlements.existing.find_by_id(self.current_settlement_id)
    if s.nil?
      raise "User stopped settlement but no current_settlement found"
    end
    s.revenue = revenue
    s.stop_by_user_id = by_user.id
    result = s.save
    if result != true
      raise "Could not save settlement because #{ s.errors.messages }"
    end
    
    s.finish
    s.print
    s.report_errors_to_technician
    
    self.current_settlement_id = nil
    result = self.save
    if result != true
      raise "Could not save user because #{ self.errors.messages }"
    end
    return s
  end
  
  def current_shift_duration
    unless self.track_time == true
      return 0
    end
    last_user_login = self.user_logins.where(:logout => nil).last
    if last_user_login
      minutes = (Time.now - last_user_login.login).to_i / 60
      return minutes
    else
      return 0
    end
  end
  
  def shift_ended
    unless self.track_time == true
      return false
    end
    return current_shift_duration >= self.maximum_shift_duration
  end
  
#   def record_history(changes, action, user, vendor, ip)
#     return if SalorHospitality::Application::CONFIGURATION[:history] != true
#     return if changes.empty?
#     
#     changes.delete("created_at")
#     changes.delete("updated_at")
#     changes.delete("last_active_at")
# 
#     h = History.new
#     h.company = self.company
#     h.vendor = vendor
#     h.user = user
#     h.model = self
#     h.ip = ip
#     h.action_taken = action
#     h.changes_made = changes
#     h.save
#     h.print
#   end

end