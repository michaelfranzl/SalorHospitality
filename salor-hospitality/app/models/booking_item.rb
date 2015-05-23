# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class BookingItem < ActiveRecord::Base
  #attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :base_price, :count, :duration, :season_id, :booking_item_id, :parent_key, :ui_id, :date_locked, :from_date, :to_date
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  belongs_to :guest_type
  belongs_to :booking_item
  belongs_to :season
  has_many :booking_items
  has_many :surcharge_items
  has_many :tax_items

  serialize :taxes
  
  alias_attribute :parent_key, :ui_parent_id
  
  # For multi-season bookings, the JS frontend maintains parent and children booking items. The parent booking items represent the first covered season. The children booking items represent all other covered seasons. We need to model and store this parent/child relationship in the DB, so that we can deliver the same relations back as JSON.
  def self.make_multiseason_associations
    BookingItem.where('ui_parent_id IS NOT NULL AND booking_item_id IS NULL').each do |bi|
      parent_item = BookingItem.find_by_ui_id(bi.ui_parent_id)
      parent_item_id = parent_item ? parent_item.id : nil
      bi.update_attribute :booking_item_id, parent_item_id
    end
    # since frontend IDs are unique only per booking form call, and they have done their due, we destroy them.
    BookingItem.where('ui_parent_id IS NOT NULL OR ui_id IS NOT NULL').update_all :ui_parent_id => nil, :ui_id => nil
  end
  
  def guest_type_id=(id)
    if id.to_i == 0
      write_attribute :guest_type_id, nil
    else
      write_attribute :guest_type_id, id
    end
  end
  
  def from_date=(from_date)
    write_attribute :from_date, DateTime.parse(from_date)
  end

  def to_date=(to_date)
    write_attribute :to_date, DateTime.parse(to_date)
  end

  # This function creates and hides SurchargeItems depending on the selection on the UI. ids contains an array of currently selected surchargeItems. That means that all other existing SurchargeItems must be hidden.
  def update_surcharge_items_from_ids(ids)
    return if ids.nil?
    # Rails loses session and params for this function if surcharges are selected in the UI. Fortunately, we can copy vendor and company from other models. It is insane, but see for yourself:
    #puts "XXXXXXXXXXXXXXXX #{@current_vendor.inspect}"
    
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    
    self.surcharge_items.each do |si|
      si.hide(0)
    end

    existing_surcharge_ids = self.surcharge_items.collect{|si| si.surcharge_id if si.surcharge}.uniq
    ids.each do |i|
      if existing_surcharge_ids.include? i.to_i
        surcharge_item = self.surcharge_items.where(:surcharge_id => i).first
        surcharge_item.update_attributes :hidden => nil, :hidden_by => nil
        surcharge_item.tax_items.update_all :hidden => nil, :hidden_by => nil
        surcharge_item.calculate_totals
        existing_surcharge_ids.delete i.to_i
      else
        s = Surcharge.find_by_id(i.to_i)
        surcharge_item = SurchargeItem.create :amount => s.amount, :vendor_id => s.vendor.id, :company_id => s.company.id, :season_id => s.season_id, :guest_type_id => s.guest_type_id, :surcharge_id => s.id, :booking_item_id => self.id, :booking_id => self.booking_id
        surcharge_item.calculate_totals
      end
      existing_surcharge_ids.each do |id|
        surcharge_item = self.surcharge_items.where(:surcharge_id => id).first
        surcharge_item.hide(0)
      end
    end
    self.save
    self.reload
  end

  def hide(by_user_id)
    self.hidden= true
    self.hidden_by = by_user_id
    self.save
    self.surcharge_items.existing.update_all :hidden => true, :hidden_by => by_user_id
    self.tax_items.existing.update_all :hidden => true, :hidden_by => by_user_id
  end
  
  def invoice_label
    label = [self.booking.room.room_type.name]
    label << self.surcharge_items.collect{ |si| si.surcharge.name }.join(', ') if self.surcharge_items.any?
    label.join(', ')
  end
  
  def tax_letters
    letters = []
    letters << self.guest_type.taxes.collect{ |t| t.letter } if self.guest_type_id
    letters << self.surcharge_items.collect do |si|
      si.surcharge.tax_amounts.collect{ |ta| ta.tax.letter }
    end
    letters.flatten!
    letters.uniq.join(', ')
  end
  
  def calculate_totals
    if self.guest_type_id.nil?
      self.base_price = 0
    else
      roomp = RoomPrice.where(:season_id => self.season_id, :room_type_id => self.booking.room.room_type_id, :guest_type_id => self.guest_type_id).first
      self.base_price = roomp.base_price
    end
    
    self.unit_sum = (self.base_price + self.surcharge_items.existing.sum(:amount)).round(3)
    self.sum = (self.unit_sum * self.count * self.duration).round(3)
    
    if self.guest_type_id.nil?
      self.calculate_taxes([])
    else
      self.calculate_taxes(self.guest_type.taxes)
    end

    self.save
  end
  
  def calculate_taxes(tax_array)
    self.taxes = {}
    tax_sum_total = 0
    tax_array.each do |tax|
      if self.vendor.country == 'us'
        net = (self.base_price * self.count * self.duration).round(3)
        gro = (net * ( 1.0 + (tax.percent / 100.0))).round(3)
      else
        gro = (self.base_price * self.count * self.duration).round(3)
        net = (gro / ( 1.0 + ( tax.percent / 100.0 ))).round(3)
      end
      tax_sum = (gro - net).round(3)
      self.taxes[tax.id] = {:p => tax.percent, :t => tax_sum, :g => gro, :n => net, :l => tax.letter, :e => tax.name }
      
      # TaxItem creation
      tax_item = TaxItem.where(:vendor_id => self.vendor_id, :company_id => self.company_id, :booking_item_id => self.id, :surcharge_item_id => nil, :tax_id => tax.id, :booking_id => self.booking_id).first
      if tax_item
        tax_item.update_attributes :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent
      else
        TaxItem.create :vendor_id => self.vendor_id, :company_id => self.company_id, :booking_item_id => self.id, :tax_id => tax.id, :booking_id => self.booking_id, :gro => gro, :net => net, :tax => tax_sum, :letter => tax.letter, :name => tax.name, :percent => tax.percent, :hidden => self.hidden, :hidden_by => self.hidden_by
      end
      tax_sum_total += tax_sum
    end

    # now, add surcharges to unit_sum, sum, and taxes hash    
    self.surcharge_items.existing.each do |si|
      si.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:t] = self.taxes[k][:t].round(3)
          self.taxes[k][:g] = self.taxes[k][:g].round(3)
          self.taxes[k][:n] = self.taxes[k][:n].round(3)
        else
          self.taxes[k] = v
        end
        tax_sum_total += v[:t]
      end
    end
    self.tax_sum = tax_sum_total
    self.save
  end
  
  def check
    self.surcharge_items.each do |si|
      si.check
    end
    
    item_hash_tax = 0
    self.taxes.each do |k,v|
      item_hash_tax += v[:t]
    end
    test1 = self.tax_sum.round(2) == item_hash_tax.round(2)
    raise "BookingItem test1 failed for id #{ self.id }" unless test1
    
    unless self.hidden
      test1a = self.tax_sum.round(2) == (self.surcharge_items.existing.sum(:tax_sum) + self.tax_items.where(:surcharge_item_id => nil).sum(:tax) ).round(2)
      raise "BookingItem test1a failed for id #{ self.id }" unless test1a
    
      test5 = self.tax_sum.round(2) == self.tax_items.existing.sum(:tax).round(2)
      raise "BookingItem test5 failed for id #{ self.id }" unless test5

      test6 = (self.sum - self.base_price * self.count * self.duration).round(2)  == self.surcharge_items.existing.sum(:sum).round(2)
      raise "BookingItem test6 failed for id #{ self.id }" unless test6
    end
    if self.hidden
      test7 = self.surcharge_items.all?{ |si| si.hidden }
      raise "BookingItem test7 failed for id #{ self.id }" unless test7
    end
    
    return true
  end
  
end
