# coding: UTF-8

# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Company < ActiveRecord::Base
  include Scope
  include ImageMethods
  
  has_many :articles
  has_many :booking_items
  has_many :bookings
  has_many :cameras
  has_many :cash_drawers
  has_many :cash_registers
  has_many :categories
  has_many :cost_centers
  has_many :coupons
  has_many :customers
  has_many :discounts
  has_many :emails
  has_many :guest_types
  has_many :histories
  has_many :images, :as => :imageable
  has_many :ingredients
  has_many :items
  has_many :option_items
  has_many :options
  has_many :orders
  has_many :pages
  has_many :partials
  has_many :payment_method_items
  has_many :payment_methods
  has_many :presentations
  has_many :quantities
  has_many :receipts
  has_many :reservations
  has_many :roles
  has_many :room_prices
  has_many :room_types
  has_many :rooms
  has_many :seasons
  has_many :settlements
  has_many :statistic_categories
  has_many :stocks
  has_many :surcharge_items
  has_many :surcharges
  has_many :tables
  has_many :tax_amounts
  has_many :tax_items
  has_many :taxes
  has_many :users
  has_many :vendor_printers
  has_many :vendors

  
  validates_presence_of :name
  validates_uniqueness_of :identifier, :scope => :hidden
  validates_uniqueness_of :name, :scope => :hidden
  
  def copy_vendor(from_vendor_id, to_vendor_id)
    vendor1 = self.vendors.where(:id => from_vendor_id).first
    vendor2 = self.vendors.where(:id => to_vendor_id).first
    raise "Vendor ID #{ from_vendor_id } is not part of this company" if vendor1.nil?
    raise "Vendor ID #{ to_vendor_id } is not part of this company" if vendor2.nil?
    
    vendor1.taxes.existing.each do |t1|
      t2 = t1.dup
      t2.vendor = vendor2
      t2.save!
    end
    
    vendor1.categories.existing.each do |c1|
      c2 = c1.dup
      c2.vendor = vendor2
      c2.vendor_printer_id = nil
      c2.preparation_user_id = nil
      c2.save!
      
      c1.articles.existing.each do |a1|
        a2 = a1.dup
        a2.vendor = vendor2
        a2.category = c2
        a2.statistic_category_id = nil
        a2.taxes = []
        a1.taxes.each do |t1|
          t2 = vendor2.taxes.find_by_percent(t1.percent)
          a2.taxes << t2
        end
        a2.price ||= 0
        a2.save!
        
        a1.quantities.existing.each do |q1|
          q2 = q1.dup
          q2.vendor = vendor2
          q2.article = a2
          q2.category = c2
          q2.statistic_category_id = nil
          q2.save!
        end
      end
    end
    
    vendor1.options.existing.each do |o1|
      o2 = o1.dup
      o2.vendor = vendor2
      o2.categories = []
      o1.categories.each do |c1|
        c2 = vendor2.categories.find_by_name(c1.name)
        o2.categories << c2
      end
      o2.save!
    end
    
  end
end
