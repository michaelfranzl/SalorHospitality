class MoveAttrsToBookingItems < ActiveRecord::Migration
  def up
    add_column :booking_items, :from_date, :datetime
    add_column :booking_items, :to_date, :datetime
    add_column :booking_items, :season_id, :integer
    add_column :booking_items, :duration, :integer
    add_column :booking_items, :original, :boolean, :default => false
    remove_column :bookings, :season_id
  end

  def down
    remove_column :booking_items, :from_date
    remove_column :booking_items, :to_date
    remove_column :booking_items, :season_id
    remove_column :booking_items, :duration
    remove_column :booking_items, :original
    add_column :bookings, :season_id, :integer
  end
end
