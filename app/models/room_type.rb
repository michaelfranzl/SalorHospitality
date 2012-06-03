class RoomType < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many :room_prices
  has_many :rooms
end
