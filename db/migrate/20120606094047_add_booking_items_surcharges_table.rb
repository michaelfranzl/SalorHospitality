class AddBookingItemsSurchargesTable < ActiveRecord::Migration
  def change
    create_table :booking_items_surcharges, :id => false do |t|
      t.integer :booking_item_id
      t.integer :surcharge_id
    end
  end
end
