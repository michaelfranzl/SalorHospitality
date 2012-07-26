# Copyright (c) 2012 Red (E) Tools Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :base_price, :count, :duration, :season_id, :booking_item_id, :parent_id, :ui_id
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  belongs_to :guest_type
  belongs_to :booking_item
  belongs_to :season
  has_many :booking_items
  has_many :surcharge_items

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

  # This function creates and hides SurchargeItems depending on the selection on the UI.
  def update_surcharge_items_from_ids(ids)
    # Rails loses session and params for this function if surcharges are selected in the UI. Fortunately, we can copy vendor and company from other models.
    #puts "XXXXXXXXXXXXXXXX #{@current_vendor.inspect}"
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    self.surcharge_items.update_all :hidden => true

    existing_surcharge_ids = self.surcharge_items.collect{|si| si.surcharge.id if si.surcharge}.uniq
    #puts "XXXXXX existing_surcharge_ids #{existing_surcharge_ids.inspect}"

    ids.each do |i|
      #puts "XXXXX sid = #{i}"
      if existing_surcharge_ids.include? i.to_i
        self.surcharge_items.where(:surcharge_id => i).update_all :hidden => nil # this should always update just one SurchargeItem
        #puts "XXXXXX Don't create SurchargeItem for surcharge##{i}. Just set hidden to false."
        existing_surcharge_ids.delete i.to_i
      else
        #puts "XXXXXX Create SurchargeItem for surcharge##{i}"
        s = Surcharge.find_by_id(i.to_i)
        surcharge_item = SurchargeItem.create :amount => s.amount, :vendor_id => s.vendor.id, :company_id => s.company.id, :season_id => s.season_id, :guest_type_id => s.guest_type_id, :surcharge_id => s.id, :booking_item_id => self.id
        self.surcharge_items << surcharge_item
        surcharge_item.calculate_totals
      end
      existing_surcharge_ids.each do |id|
        #puts "XXXXXX hiding surcharge_items for surcharge##{id}"
        self.surcharge_items.where(:surcharge_id => id).update_all :hidden => true
      end
    end
    self.save
    self.reload
  end

  def hide
    self.update_attribute :hidden, true
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
    letters.join(', ')
  end
  
  def calculate_totals
    #puts "XXXXXXXXXX BookingItem -> calculate_totals #{ self.id }"
    if self.guest_type_id.nil?
      self.base_price = 0
    else
      roomp = RoomPrice.where(:season_id => self.season_id, :room_type_id => self.booking.room.room_type_id, :guest_type_id => self.guest_type_id).first
      self.base_price = roomp.base_price
    end
    
    self.unit_sum = self.base_price
    self.sum = self.unit_sum * self.count * self.duration
    
    # below, calculate taxes
    self.taxes = {}
    unless self.guest_type_id.nil?
      #puts "  XXX for base_price"
      self.guest_type.taxes.each do |tax|
        #puts "    XXX tax #{tax.id} of guest_type #{ self.guest_type.id }"
        tax_sum = (self.sum * ( tax.percent / 100.0 )).round(2)
        gro = (self.sum).round(2)
        #puts "XXXXXXXXXXX self.taxes is #{ self.taxes.inspect }"
        #puts "XXXXXXXXXXX gro is #{gro}"
        net = (gro - tax_sum).round(2)
        self.taxes[tax.id] = {:p => tax.percent, :t => tax_sum, :g => gro, :n => net, :l => tax.letter, :e => tax.name }
        #puts "XXXXXXXXXXX self.taxes is #{ self.taxes.inspect }"
        #puts "    XXX setting self.taxes to #{self.taxes.inspect}"
      end
    end
    
    # now, add surcharges to unit_sum, sum, and taxes hash    
    self.unit_sum += self.surcharge_items.sum(:amount)
    self.sum += self.surcharge_items.sum(:sum)
    self.surcharge_items.each do |si|
      #puts "XXXXXXX Adding surcharge taxes to booking_item"
      si.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:t] += v[:t]
          self.taxes[k][:g] += v[:g]
          self.taxes[k][:n] += v[:n]
          self.taxes[k][:t] = self.taxes[k][:t].round(2)
          self.taxes[k][:g] = self.taxes[k][:g].round(2)
          self.taxes[k][:n] = self.taxes[k][:n].round(2)
        else
          self.taxes[k] = v
        end
      end
    end
    self.hide if self.count.zero?
    save
  end
  
end
