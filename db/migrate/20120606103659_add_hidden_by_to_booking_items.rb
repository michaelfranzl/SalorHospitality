class AddHiddenByToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :hidden_by, :integer
  end
end
