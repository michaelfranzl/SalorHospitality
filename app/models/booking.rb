class Booking < ActiveRecord::Base
  attr_accessible :company_id, :customer_id, :from, :hidden, :note, :paid, :sum, :to, :vendor_id
end
