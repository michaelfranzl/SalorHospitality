class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :surchargeslist, :base_price, :count
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  has_and_belongs_to_many :surcharges

  def surchargeslist=(ids)
    self.surcharges = []
    ids.each do |i|
      self.surcharges << Surcharge.find_by_id(i.to_i)
    end
    self
  end

  
end
