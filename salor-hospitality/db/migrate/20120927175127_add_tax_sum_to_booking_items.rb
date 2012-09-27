class AddTaxSumToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :tax_sum, :float
  end
end
