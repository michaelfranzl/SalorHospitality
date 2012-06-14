class Room < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  belongs_to :room_type
  has_many :bookings

  validates_presence_of :name, :room_type_id
  validates_uniqueness_of :name
end
