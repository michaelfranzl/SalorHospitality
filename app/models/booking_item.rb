class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id
end
