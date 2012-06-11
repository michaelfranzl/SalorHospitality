class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :base_price, :count
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  belongs_to :guest_type
  has_many :surcharge_items

  serialize :taxes

  # This function creates and hides SurchargeItems depending on the selection on the UI.
  def update_surcharge_items_from_ids(ids)
    # Rails loses session and params for this function if surcharges are selected in the UI. Fortunately, we can copy vendor and company from other models.
    #puts "XXXXXXXXXXXXXXXX #{@current_vendor.inspect}"
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    self.surcharge_items.update_all :hidden => true

    existing_surcharge_ids = self.surcharge_items.collect{|si| si.surcharge.id}.uniq
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
        surcharge_item.calculate_totals
      end
      existing_surcharge_ids.each do |id|
        #puts "XXXXXX hiding surcharge_items for surcharge##{id}"
        self.surcharge_items.where(:surcharge_id => id).update_all :hidden => true
      end
    end
  end

  def hide
    self.update_attribute :hidden, true
  end

  def calculate_totals
    self.base_price = RoomPrice.where(:season_id => self.booking.season_id, :room_type_id => self.booking.room.room_type_id, :guest_type_id => self.guest_type_id).first.base_price
    self.sum = self.count * (self.base_price + self.surcharge_items.sum(:amount))
    self.guest_type.taxes.each do |tax|
      tax_sum = (self.sum * ( tax.percent / 100.0 )).round(2)
      gro = (self.sum).round(2)
      net = (gro - tax_sum).round(2)
      self.taxes[tax.id] = {:percent => tax.percent, :tax => tax_sum, :gro => gro, :net => net, :letter => tax.letter, :name => tax.name }
    end
    self.surcharge_items.each do |si|
      si.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:tax] += v[:tax]
          self.taxes[k][:tax] = self.taxes[k][:tax].round(2)
          self.taxes[k][:gro] += (v[:gro]).round(2)
          self.taxes[k][:net] += (v[:net]).round(2)
        else
          self.taxes[k] = v
        end
      end
    end
    self.hide if self.count.zero?
    save
  end
  
end
