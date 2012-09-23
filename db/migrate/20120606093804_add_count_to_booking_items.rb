class AddCountToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :count, :integer, :default => 1
  end
end
