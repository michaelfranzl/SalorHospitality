class AddDateLockedToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :date_locked, :boolean, :default => false
  end
end
