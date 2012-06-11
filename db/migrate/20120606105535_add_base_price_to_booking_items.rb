class AddBasePriceToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :base_price, :float
  end
end
