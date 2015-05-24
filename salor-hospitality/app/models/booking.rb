# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Booking < ActiveRecord::Base
  #attr_accessible :company_id, :customer_id, :hidden, :note, :paid, :sum, :vendor_id, :room_id, :user_id, :season_id, :booking_items_to_json, :taxes, :change_given, :from_date, :to_date, :duration, :tax_sum
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
  #attr_accessible :customer_name
  
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
  
  def set_nr
    if self.nr.nil?
      self.update_attribute :nr, self.vendor.get_unique_model_number('booking')
    end
  end
  
  def customer_name
    if self.customer then
      return self.customer.full_name(true)
    end
    return ""
  end

  def customer_name=(name)
    if name.blank?
      self.customer = nil
      self.save!
      return
    end
    last,first = name.split(',')
    return if not last or not first
    c = self.company.customers.existing.where(:first_name => first.strip, :last_name => last.strip).first
    if not c then
      # create new customer
      c = Customer.new
      c.first_name = first.strip
      c.last_name = last.strip
      c.vendor_id = self.vendor_id
      c.company_id = self.company_id
      c.login = "#{last.strip}#{first.strip}"
      c.password = Time.now.strftime("%Y%m%d%H%M%S")
      c.email = Time.now.strftime("%Y%m%d%H%M%S")
      c.save!
      self.vendor.update_cache
    end
    self.customer = c
    self.save
  end
  
  def self.create_from_params(params, vendor, user)
    booking = Booking.new
    booking.user = user
    booking.vendor = vendor
    booking.company = vendor.company
    
    permitted = params.require(:model).permit :room_id,
       :duration,
       :from_date,
       :to_date,
       :id,
       :hidden
    
    booking.update_attributes permitted
    params[:items].to_a.each do |item_params|
      booking.create_new_item(item_params)
    end
    booking.save
    booking.update_associations(user)
    booking.calculate_totals
    BookingItem.make_multiseason_associations
    booking.update_payment_method_items(params)
    booking.hide(user.id) if booking.hidden
    booking.set_nr
    return booking
  end

  def update_from_params(params, user)
    permitted = params.require(:model).permit :room_id,
       :duration,
       :from_date,
       :to_date,
       :id,
       :hidden
    
    self.update_attributes permitted
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        self.update_item(item_id, item_params)
      else
        self.create_new_item(item_params)
      end
    end
    self.hide(user.id) if self.hidden
    self.save
    self.update_associations(user)
    self.calculate_totals
    BookingItem.make_multiseason_associations
    self.update_payment_method_items(params)
  end
  
  def create_new_item(p)
    key = p[0]
    params = ActionController::Parameters.new(p[1])
    i = BookingItem.new
    permitted = params.permit :count,
        :guest_type_id,
        :duration,
        :season_id,
        :from_date,
        :to_date,
        :base_price,
        :count,
        :hidden
    i.update_attributes permitted
    i.ui_id = key
    i.room_id = self.room_id
    i.booking = self
    i.vendor = vendor
    i.company = vendor.company
    i.save!
    i.update_surcharge_items_from_ids p[1][:surchargeslist]
    i.surcharge_items.each do |si|
      si.calculate_totals
    end
    i.calculate_totals
    i.hide(user.id) if i.hidden or i.count.zero?
  end
  
  def update_item(id, p)
    key = p[0]
    params = ActionController::Parameters.new(p[1])
    i = BookingItem.find_by_id(id)
    permitted = params.permit :count,
        :guest_type_id,
        :duration,
        :season_id,
        :from_date,
        :to_date,
        :base_price,
        :count,
        :hidden
    i.update_attributes permitted
    i.update_attribute :ui_id, key
    i.update_surcharge_items_from_ids p[1][:surchargeslist]
    i.surcharge_items.existing.each { |si| si.calculate_totals }
    i.calculate_totals
    i.hide(user.id) if i.hidden or i.count.zero?
  end
  
  def update_payment_method_items(params)
    if params[:payment_method_items] then
      self.payment_method_items.clear
      params['payment_method_items'][params['id']].to_a.each do |pm|
        if pm[1]['amount'].to_f > 0 and pm[1]['_delete'].to_s == 'false'
          payment_method = self.vendor.payment_methods.existing.find_by_id(pm[1]['id'])
          PaymentMethodItem.create(
            :payment_method_id => pm[1]['id'],
            :amount => pm[1]['amount'],
            :booking_id => self.id,
            :vendor_id => self.vendor_id,
            :company_id => self.company_id,
            :cash => payment_method.cash
          )
        end
      end
    end
  end

  def pay
    self.finish
    
    # create a default cash payment method item if none was set in the UI
    unless self.payment_method_items.existing.any?
      cash_payment_method = self.vendor.payment_methods.existing.where(:cash => true).first
      if cash_payment_method
        PaymentMethodItem.create(
          :company_id => self.company_id,
          :vendor_id => self.vendor_id,
          :booking_id => self.id,
          :payment_method_id => cash_payment_method.id,
          :cash => true,
          :amount => self.sum
        )
      end
    end
    
    payment_method_sum = self.payment_method_items.existing.sum(:amount) # refunded is never true at this point
    
    # create a change payment method item
    change_payment_method = self.vendor.payment_methods.existing.where(:change => true).first
    if change_payment_method
      PaymentMethodItem.create(
        :company_id => self.company_id,
        :vendor_id => self.vendor_id,
        :booking_id => self.id,
        :change => true,
        :amount => (payment_method_sum - self.sum).round(2),
        :payment_method_id => change_payment_method.id
      )
    end
    
    self.change_given = (payment_method_sum - self.sum).round(2)
    self.paid = true
    self.paid_at = Time.now
    self.orders.existing.update_all :paid => true, :paid_at => Time.now
    self.save
  end

  def finish
    self.finished = true
    self.finished_at = Time.now
    self.save
  end

  def update_associations(user)
    self.user = user
    save
  end

  def booking_items_to_json
    booking_items_hash = {}
    self.booking_items.existing.each do |i|
      d = i.booking_item_id ? "x#{i.id}" : "i#{i.id}"
      parent_key = i.booking_item_id ? "i#{i.booking_item_id}" : nil
      surcharges = self.vendor.surcharges.where(
        :season_id => i.season_id,
        :guest_type_id => i.guest_type_id
      )
      surcharges_hash = {}
      surcharges.each do |s|
        booking_item_surcharges = i.surcharge_items.existing.collect { |si| si.surcharge }
        selected = booking_item_surcharges.include?(s) and s.amount > 0
        surcharges_hash.merge! s.name => {
          :id => s.id,
          :amount => s.amount,
          :radio_select => s.radio_select,
          :selected => selected
        }
      end
      booking_items_hash.merge! d => {
        :id => i.id,
        :base_price => i.base_price,
        :count => i.count,
        :guest_type_id => i.guest_type_id,
        :from_date => i.from_date.strftime('%Y-%m-%d'),
        :to_date => i.to_date.strftime('%Y-%m-%d'),
        :date_locked => i.date_locked,
        :duration => i.duration,
        :season_id => i.season_id,
        :parent_key => parent_key,
        :surcharges => surcharges_hash
      }
    end
    return booking_items_hash.to_json
  end

  def calculate_totals
    self.sum = self.booking_item_sum = self.booking_items.existing.where(:booking_id => self.id).sum(:sum).round(3)
    self.sum += Order.where(:booking_id => self.id).existing.sum(:sum)
    self.sum = self.sum.round(3)
    self.refund_sum = self.booking_items.existing.sum(:refund_sum).round(3)
    self.tax_sum = self.booking_items.existing.sum(:tax_sum)
    self.tax_sum += Order.where(:booking_id => self.id).existing.sum(:tax_sum)
    self.tax_sum = self.tax_sum.round(3)
    self.save
    self.calculate_taxes
    self.set_booking_date
    self.save
  end
  
  def calculate_taxes
    self.taxes = {}
    self.booking_items.existing.each do |item|
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:g] = self.taxes[k][:g].round(3)
          self.taxes[k][:n] = self.taxes[k][:n].round(3)
          self.taxes[k][:t] = self.taxes[k][:t].round(3)
        else
          self.taxes[k] = v
        end
      end
    end
    self.orders.each do |order|
      order.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] = self.taxes[k][:g].round(3)
          self.taxes[k][:n] = self.taxes[k][:n].round(3)
          self.taxes[k][:t] = self.taxes[k][:t].round(3)
        else
          self.taxes[k] = v
        end
      end
    end
  end
  
  def from_date=(from_date)
    if self.booking_items.existing.where(:date_locked => false).any?
      self.booking_items.existing.where(:date_locked => false).update_all :from_date => from_date
      self.set_booking_date
    else
      write_attribute :from_date, from_date
    end
  end
  
  def to_date=(to_date)
    if self.booking_items.existing.where(:date_locked => false).any?
      self.booking_items.existing.where(:date_locked => false).update_all :to_date => to_date
      self.set_booking_date
    else
      write_attribute :to_date, to_date
    end
  end
  
  
  def set_booking_date
    if self.booking_items.existing.any?
      write_attribute :from_date, self.booking_items.existing.collect{ |bi| bi.from_date }.min
      write_attribute :to_date, self.booking_items.existing.collect{ |bi| bi.to_date }.max
      self.duration = (self.to_date - self.from_date) / 86400
    end
    self.save
  end

  def hide(by_user_id)
    self.vendor.unused_booking_numbers << self.nr
    self.vendor.save
    
    self.nr = nil
    self.hidden = true
    self.hidden_by = by_user_id
    self.save
    
    self.booking_items.update_all :hidden => true, :hidden_by => by_user_id
    self.surcharge_items.update_all :hidden => true, :hidden_by => by_user_id
    self.tax_items.update_all :hidden => true, :hidden_by => by_user_id
  end

  def info_for_order_assignment
    "#{ self.room.name } #{ self.customer.full_name if self.customer }"
  end
  
  def check
    self.orders.existing.each do |o|
      o.check
    end
    
    self.booking_items.existing.each do |bi|
      bi.check
    end
    
    test1 = self.sum.round(2) == (self.booking_items.existing.sum(:sum) + self.orders.existing.sum(:sum)).round(2)
    raise "Booking test1 failed for id #{ self.id }" unless test1
    
    test2 = self.booking_item_sum.round(2) == self.booking_items.existing.sum(:sum).round(2)
    raise "Booking test2 failed for id #{ self.id }" unless test2
    
    test3 = self.tax_sum.round(2) == (self.booking_items.existing.sum(:tax_sum) + self.orders.existing.sum(:tax_sum)).round(2)
    raise "Booking test3 failed for id #{ self.id }" unless test3
    
    if self.hidden
      test4 = self.tax_items.all?{|ti| ti.hidden} && self.surcharge_items.all?{|si| si.hidden} && self.booking_items.all?{|bi| bi.hidden}
      raise "Booking test4 failed for id #{ self.id }" unless test4
    end
    
    booking_tax_sum = 0
    self.taxes.each do |k,v|
      booking_tax_sum += v[:t]
    end
    test5 = self.tax_sum.round(2) == booking_tax_sum.round(2)
    raise "Booking test5 failed for id #{ self.id }" unless test5
    
    test6 = self.tax_sum.round(2) == (self.tax_items.existing.sum(:tax) + self.orders.collect{|o| TaxItem.where(:order_id => o.id).existing.sum(:tax)}.sum ).round(2)
    raise "Booking test6 failed for id #{ self.id }" unless test6
    
    return true
  end
end
