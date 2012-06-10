class Booking < ActiveRecord::Base
  attr_accessible :company_id, :customer_id, :from, :hidden, :note, :paid, :sum, :to, :vendor_id, :room_id, :user_id, :season_id, :booking_items_to_json, :duration, :taxes, :change_given
  include Scope
  has_many :booking_items
  has_many :payment_method_items
  has_many :orders
  belongs_to :room
  belongs_to :user
  belongs_to :vendor
  belongs_to :company
  belongs_to :season
  belongs_to :customer

  serialize :taxes

  def self.create_from_params(params, vendor, user)
    booking = Booking.new params[:model]
    booking.user = user
    booking.vendor = vendor
    booking.company = vendor.company
    params[:items].to_a.each do |item_params|
      new_item = BookingItem.new(item_params[1])
      booking.booking_items << new_item
      booking.save
      new_item.calculate_totals
    end
    booking.save
    return booking
  end

  def set_nr
    if self.nr.nil?
      self.update_attribute :nr, self.vendor.get_unique_model_number('order')
    end
  end

  def update_from_params(params)
    self.update_attributes params[:model]
    params[:items].to_a.each do |item_params|
      item_id = item_params[1][:id]
      if item_id
        item_params[1].delete(:id)
        item = BookingItem.find_by_id(item_id)
        item.update_attributes(item_params[1])
        item.calculate_totals
      else
        new_item = BookingItem.new(item_params[1])
        self.booking_items << new_item
        self.save
        new_item.calculate_totals
      end
    end
  end

  def from=(from)
    write_attribute :from, DateTime.parse(from)
  end

  def to=(to)
    write_attribute :to, DateTime.parse(to)
  end

  def pay
    self.finish
    self.change_given = - (self.sum - self.payment_method_items.sum(:amount))
    self.change_given = 0 if self.change_given < 0
    self.paid = true
    self.save
  end

  def finish
    self.update_attribute :finished, true
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

  def calculate_totals
    self.sum = booking_items.existing.sum(:sum)
    self.sum *= self.duration
    self.refund_sum = booking_items.existing.sum(:refund_sum)
    self.taxes = {}
    self.booking_items.each do |item|
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:tax] += v[:tax]
          self.taxes[k][:gro] += v[:gro]
          self.taxes[k][:net] += v[:net]
        else
          self.taxes[k] = v
        end
      end
    end
    self.orders.each do |order|
      order.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:gro] += v[:gro]
          self.taxes[k][:net] += v[:net]
          self.taxes[k][:tax] += v[:tax]
        else
          self.taxes[k] = v
        end
      end
    end
    save
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
