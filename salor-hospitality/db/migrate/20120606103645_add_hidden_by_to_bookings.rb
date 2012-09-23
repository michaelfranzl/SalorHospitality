class AddHiddenByToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :hidden_by, :integer
  end
end
