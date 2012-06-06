class Booking < ActiveRecord::Base
  attr_accessible :company_id, :customer_id, :from, :hidden, :note, :paid, :sum, :to, :vendor_id, :room_id, :user_id, :season_id, :booking_items_to_json
  include Scope
  has_many :booking_items
  belongs_to :room
  belongs_to :user
  belongs_to :vendor
  belongs_to :company
  belongs_to :season


  def self.create_from_params(params, vendor, user)
    booking = Booking.new params[:model]
    booking.user = user
    booking.vendor = vendor
    booking.company = vendor.company
    params[:items].to_a.each do |item_params|
      new_item = BookingItem.new(item_params[1])
      booking.booking_items << new_item
    end
    booking.save
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
      else
        new_item = BookingItem.new(item_params[1])
        self.booking_items << new_item
      end
    end
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
    self.booking_items.existing.reverse.each do |i|
      d = "i#{i.id}"
      surcharges_hash = {}
      surcharges = self.vendor.surcharges.where(:season_id => self.season_id, :guest_type_id => i.guest_type_id)
      surcharges.each do |s|
        selected = i.surcharges.include? s
        surcharges_hash.merge! s.name => { :id => s.id, :amount => s.amount, :radio_select => s.radio_select, :selected => selected }
      end
      booking_items_hash.merge! d => { :id => i.id, :base_price => i.base_price, :count => i.count, :guest_type_id => i.guest_type_id, :surcharges => surcharges_hash }
    end
    return booking_items_hash.to_json
  end

  def hide(by_user_id)
    self.hidden = true
    self.hidden_by = by_user_id
    save
  end
end
