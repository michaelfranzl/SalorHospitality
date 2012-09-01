# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Booking < ActiveRecord::Base
  attr_accessible :company_id, :customer_id, :hidden, :note, :paid, :sum, :vendor_id, :room_id, :user_id, :season_id, :booking_items_to_json, :taxes, :change_given, :from_date, :to_date, :duration
  include Scope
  has_many :booking_items
  has_many :payment_method_items
  has_many :orders
  has_many :surcharge_items
  has_many :tax_items
  belongs_to :room
  belongs_to :user
  belongs_to :vendor
  belongs_to :company
  belongs_to :customer

  serialize :taxes
  attr_accessible :customer_name
  
  def as_json(options={})
    return {
        :from => self.from_date.strftime("%Y-%m-%d"),
        :to => self.to_date.strftime("%Y-%m-%d"),
        :id => self.id,
        :customer_name => self.customer_name,
        :room_id => self.room_id,
        :duration => self.duration,
        :hidden => self.hidden,
        :finished => self.finished,
        :paid => self.paid
      }
  end
  
  def customer_name
    if self.customer then
      return self.customer.full_name(true)
    end
    return ""
  end
  
  def set_nr
    if self.nr.nil?
      self.update_attribute :nr, self.vendor.get_unique_model_number('booking')
    end
  end
  
  def customer_name=(name)
    last,first = name.split(',')
    return if not last or not first
    c = Customer.where(:first_name => first.strip, :last_name => last.strip).first
    if not c then
      c = Customer.create(:first_name => first.strip,:last_name => last.strip, :vendor_id => self.vendor_id, :company_id => self.company_id)
    end
    self.customer = c
  end
  
  def self.create_from_params(params, vendor, user)
    booking = Booking.new
    booking.user = user
    booking.vendor = vendor
    booking.company = vendor.company
    booking.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      new_item = BookingItem.create(item_params[1])
      new_item.ui_id = item_params[0]
      new_item.booking = booking
      new_item.room_id = booking.room_id
      new_item.save
      new_item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
      new_item.calculate_totals
    end
    booking.save
    booking.calculate_totals
    BookingItem.make_multiseason_associations
    booking.update_payment_method_items(params)
    return booking
  end


  def update_from_params(params)
    self.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        item_params[1].delete(:id)
        item = BookingItem.find_by_id(item_id)
        item.update_attributes(item_params[1])
        item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
        item.update_attribute :ui_id, item_params[0]
        item.calculate_totals
      else
        new_item = BookingItem.new(item_params[1])
        new_item.ui_id = item_params[0]
        new_item.room_id = self.room.id
        new_item.save
        self.booking_items << new_item
        new_item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
        new_item.calculate_totals
      end
    end
    BookingItem.make_multiseason_associations
    self.save
    self.update_payment_method_items(params)
  end
  
  def update_payment_method_items(params)
    if params[:payment_method_items] then
      self.payment_method_items.clear
      params['payment_method_items'][params['id']].to_a.each do |pm|
        if pm[1]['amount'].to_f > 0 and pm[1]['_delete'].to_s == 'false'
          PaymentMethodItem.create :payment_method_id => pm[1]['id'], :amount => pm[1]['amount'], :booking_id => self.id, :vendor_id => self.vendor_id, :company_id => self.company_id
        end
      end
    end
  end

  def pay
    self.finish
    self.change_given = - (self.sum - self.payment_method_items.sum(:amount))
    self.change_given = 0 if self.change_given < 0
    self.paid = true
    self.orders.existing.update_all :paid => true
    self.save
  end

  def finish
    self.finished = true
    self.finished_at = Time.now
    self.save
  end

  def update_associations(user)
    self.user = user
    self.booking_items.each do |i|
      i.update_attributes :vendor_id => self.vendor.id, :company_id => self.company.id
    end
    save
  end

  def booking_items_to_json
    booking_items_hash = {}
    self.booking_items.existing.each do |i|
      d = i.booking_item_id ? "x#{i.id}" : "i#{i.id}"
      parent_key = i.booking_item_id ? "i#{i.booking_item_id}" : nil
      surcharges = self.vendor.surcharges.where(:season_id => i.season_id, :guest_type_id => i.guest_type_id)
      surcharges_hash = {}
      surcharges.each do |s|
        booking_item_surcharges = i.surcharge_items.existing.collect { |si| si.surcharge }
        selected = booking_item_surcharges.include?(s) and s.amount > 0
        surcharges_hash.merge! s.name => { :id => s.id, :amount => s.amount, :radio_select => s.radio_select, :selected => selected }
      end
      booking_items_hash.merge! d => { :id => i.id, :base_price => i.base_price, :count => i.count, :guest_type_id => i.guest_type_id, :from_date => i.from_date.strftime('%Y-%m-%d'), :to_date => i.to_date.strftime('%Y-%m-%d'), :date_locked => i.date_locked, :duration => i.duration, :season_id => i.season_id, :parent_key => parent_key, :surcharges => surcharges_hash }
    end
    return booking_items_hash.to_json
  end

  def calculate_totals
    #puts "XXXXXXXXXX calculate_totals for Booking"
    self.sum = self.booking_item_sum = self.booking_items.existing.where(:booking_id => self.id).sum(:sum)
    self.refund_sum = booking_items.existing.sum(:refund_sum)
    self.taxes = {}
    self.booking_items.existing.each do |item|
      #puts "  XXX booking_item #{item.id}"
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          #puts "XXX has key"
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:g] = self.taxes[k][:g].round(2)
          self.taxes[k][:n] = self.taxes[k][:n].round(2)
          self.taxes[k][:t] = self.taxes[k][:t].round(2)
        else
          #puts "XXX has not key"
          self.taxes[k] = v
        end
      end
    end
    self.sum += Order.where(:booking_id => self.id).sum(:sum)
    self.orders.each do |order|
      order.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] = self.taxes[k][:g].round(2)
          self.taxes[k][:n] = self.taxes[k][:n].round(2)
          self.taxes[k][:t] = self.taxes[k][:t].round(2)
        else
          self.taxes[k] = v
        end
      end
    end
    set_booking_date
    save
  end
  
  def set_booking_date
    if self.booking_items.existing.any?
      self.from_date = self.booking_items.existing.collect{ |bi| bi.from_date }.min
      self.to_date = self.booking_items.existing.collect{ |bi| bi.to_date }.max
      self.duration = (self.to_date - self.from_date) / 86400
    end
    self.save
  end

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    save
  end

  def info_for_order_assignment
    "#{ self.room.name } #{ self.customer.full_name if self.customer }"
  end
end
