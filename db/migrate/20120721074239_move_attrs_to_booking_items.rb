class MoveAttrsToBookingItems < ActiveRecord::Migration
  def up
    add_column :booking_items, :from_date, :datetime
    add_column :booking_items, :to_date, :datetime
    add_column :booking_items, :season_id, :integer
    add_column :booking_items, :duration, :integer
    add_column :booking_items, :booking_item_id, :integer
    add_column :booking_items, :ui_parent_id, :string
    add_column :booking_items, :ui_id, :string
    remove_column :bookings, :season_id
  end

  def down
    remove_column :booking_items, :from_date
    remove_column :booking_items, :to_date
    remove_column :booking_items, :season_id
    remove_column :booking_items, :duration
    remove_column :booking_items, :booking_item_id
    remove_column :booking_items, :ui_parent_id
    remove_column :booking_items, :ui_id
    add_column :bookings, :season_id, :integer
  end
end
