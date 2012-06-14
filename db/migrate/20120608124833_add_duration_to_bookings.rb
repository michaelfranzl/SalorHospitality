class AddDurationToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :duration, :float
  end
end
