class AddBookingIdToSurchargeItems < ActiveRecord::Migration
  def change
    add_column :surcharge_items, :booking_id, :integer
  end
end
