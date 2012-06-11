class SurchargeItem < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :surcharge
  belongs_to :booking_item

  serialize :taxes
end
