class Booking < ActiveRecord::Base
  attr_accessible :company_id, :customer_id, :from_date, :hidden, :note, :paid, :sum, :to_date, :vendor_id, :room_id, :user_id, :season_id, :booking_items_to_json, :duration, :taxes, :change_given
  include Scope
  has_many :booking_items
  has_many :payment_method_items
  has_many :orders
  has_many :surcharge_items
  belongs_to :room
  belongs_to :user
  belongs_to :vendor
  belongs_to :company
  belongs_to :season
  belongs_to :customer

  serialize :taxes
  attr_accessible :customer_name
  def as_json(options={})
    return {
        :from => self.from_date,
        :to => self.to_date,
        :id => self.id,
        :customer_name => self.customer_name,
        :room_id => self.room_id,
        :duration => self.duration
      }
  end
  def self.create_from_params(params, vendor, user)
    booking = Booking.create params[:model]
    booking.user = user
    booking.vendor = vendor
    booking.company = vendor.company
    params[:items].to_a.each do |item_params|
      new_item = BookingItem.new(item_params[1])
      new_item.booking = booking
      new_item.calculate_totals
      #new_item.save
      new_item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
    end
    booking.save
    booking.calculate_totals
    return booking
  end
  def customer_name=(name)
    last,first = name.split(',')
    return if not last or not first
    c = Customer.where(:first_name => first.strip, :last_name => last.strip).first
    if not c then
      c = Customer.create(:first_name => first.strip,:last_name => last.strip)
    end
    self.customer = c
  end
  def customer_name
    if self.customer then
      return self.customer.full_name(true)
    end
    return ""
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
        item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
        # item.calculate_totals # this was already called in update_surcharge_items_from_ids
      else
        new_item = BookingItem.create(item_params[1])
        self.booking_items << new_item
        new_item.update_surcharge_items_from_ids(item_params[1][:surchargeslist]) if item_params[1][:surchargeslist]
        # new_item.calculate_totals # this was already called in update_surcharge_items_from_ids
      end
    end
    self.save
  end

  def from=(from)
    write_attribute :from, DateTime.parse(from)
  end

  def to=(to)
    write_attribute :to, DateTime.parse(to)
  end

  def pay
    self.finish
    puts self.sum
    puts self.payment_method_items.sum(:amount)
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
      if i.guest_type_id.zero?
        d = "s#{i.id}"
        surcharges = self.vendor.surcharges.where(:season_id => self.season_id)
      else
        d = "i#{i.id}"
        surcharges = self.vendor.surcharges.where(:season_id => self.season_id, :guest_type_id => i.guest_type_id)
      end
      surcharges_hash = {}
      surcharges.each do |s|
        booking_item_surcharges = i.surcharge_items.existing.collect { |si| si.surcharge }
        selected = booking_item_surcharges.include? s
        surcharges_hash.merge! s.name => { :id => s.id, :amount => s.amount, :radio_select => s.radio_select, :selected => selected }
      end
      booking_items_hash.merge! d => { :id => i.id, :base_price => i.base_price, :count => i.count, :guest_type_id => i.guest_type_id, :surcharges => surcharges_hash }
    end
    return booking_items_hash.to_json
  end

  def calculate_totals
    self.sum = self.duration * self.booking_items.existing.where(:booking_id => self.id).sum(:sum)
    self.refund_sum = booking_items.existing.sum(:refund_sum)
    self.taxes = {}
    self.booking_items.each do |item|
      puts "XXX booking_item #{item.id}"
      item.taxes.each do |k,v|
        if self.taxes.has_key? k
          puts "XXX has key"
          self.taxes[k][:tax] += v[:tax].round(2)
          self.taxes[k][:gro] += v[:gro].round(2)
          self.taxes[k][:net] += v[:net].round(2)
        else
          puts "XXX has not key"
          self.taxes[k] = v
        end
      end
    end
    self.sum += Order.where(:booking_id => self.id).sum(:sum)
    self.orders.each do |order|
      order.taxes.each do |k,v|
        if self.taxes.has_key? k
          self.taxes[k][:gro] += v[:gro].round(2)
          self.taxes[k][:net] += v[:net].round(2)
          self.taxes[k][:tax] += v[:tax].round(2)
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
