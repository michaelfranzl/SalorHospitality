class ChangeBookingSumDefault < ActiveRecord::Migration
  def up
    change_column :bookings, :sum, :float, :default => 0
    change_column :booking_items, :sum, :float, :default => 0
    add_column :booking_items, :refund_sum, :float, :default => 0
    add_column :booking_items, :tax_sum, :float, :default => 0
    add_column :bookings, :refund_sum, :float, :default => 0
    add_column :bookings, :tax_sum, :float, :default => 0
  end

  def down
    remove_column :booking_items, :refund_sum
    remove_column :booking_items, :tax_sum
    remove_column :bookings, :refund_sum
    remove_column :bookings, :tax_sum
  end
end
