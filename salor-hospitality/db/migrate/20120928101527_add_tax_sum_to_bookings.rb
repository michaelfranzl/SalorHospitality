class AddTaxSumToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :tax_sum, :float
  end
end
