class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :surchargeslist, :base_price, :count
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  belongs_to :guest_type
  has_many :surcharge_items

  serialize :taxes

  def surchargeslist=(ids)
    puts "111111111111111 #{ @current_vendor.inspect }"
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    surcharge_items = []
    ids.each do |i|
      s = Surcharge.find_by_id(i.to_i)
      puts "XXXXXXXXXXXXXXXX #{ @current_vendor.inspect }"
      surcharge_item = SurchargeItem.new :amount => s.amount, :vendor_id => @current_vendor.id, :company_id => @current_company.id, :season_id => s.season_id, :guest_type_id => s.guest_type_id
      surcharge_item_taxes = {}
      s.tax_amounts.each do |ta|
        tax_object = ta.tax
        tax_sum = (ta.amount * ( tax_object.percent / 100.0 )).round(2)
        gro = (ta.amount).round(2)
        net = (gro - tax_sum).round(2)
        surcharge_item.taxes[tax_object.id] = {:percent => tax_object.percent, :tax => tax_sum, :gro => gro, :net => net, :letter => tax_object.letter, :name => tax_object.name }
      end
      surcharge_item.save
    end
    self
  end

  def surchargeslist
    return "nothing"
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
