class GuestType < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :room_prices
  has_many :surcharges
  has_many :booking_items
  has_and_belongs_to_many :taxes
end
