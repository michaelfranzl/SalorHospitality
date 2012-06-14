class RoomPrice < ActiveRecord::Base
  include Scope
  belongs_to :vendor
  belongs_to :company
  has_many   :rooms
  belongs_to :room_type
  belongs_to :guest_type
  belongs_to :season

  def self.generate(vendor)
    seasons = vendor.seasons.existing
    room_types = vendor.room_types.existing
    guest_types = vendor.guest_types.existing
    seasons.each do |s|
      room_types.each do |rt|
        guest_types.each do |gt|
          unless vendor.room_prices.existing.where(:season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id).any?
            RoomPrice.create :vendor_id => vendor.id, :company_id => vendor.company.id, :season_id => s.id, :room_type_id => rt.id, :guest_type_id => gt.id, :base_price => 0
          end
        end
      end
    end
  end
end
