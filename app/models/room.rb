class Room < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :room_type
  has_many :bookings
  has_many :orders
end
