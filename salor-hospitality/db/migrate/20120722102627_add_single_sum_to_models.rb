class AddSingleSumToModels < ActiveRecord::Migration
  def up
    add_column :surcharge_items, :sum, :float
    add_column :surcharge_items, :duration, :integer
    add_column :surcharge_items, :count, :integer
    add_column :booking_items, :unit_sum, :float
    add_column :bookings, :booking_item_sum, :float
  end
  def down
    remove_column :surcharge_items, :sum
    remove_column :surcharge_items, :duration
    remove_column :surcharge_items, :count
    remove_column :booking_items, :unit_sum
    remove_column :bookings, :booking_item_sum
  end
end
