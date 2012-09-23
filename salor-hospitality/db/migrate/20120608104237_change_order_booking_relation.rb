class ChangeOrderBookingRelation < ActiveRecord::Migration
  def change
    remove_column :orders, :room_id
    add_column :orders, :booking_id, :integer
  end
end
