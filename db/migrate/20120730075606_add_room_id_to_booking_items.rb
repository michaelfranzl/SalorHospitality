class AddRoomIdToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :room_id, :integer
  end
end
