class RoomPrice < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many   :rooms
  belongs_to :room_type
  belongs_to :guest_type
end
