class AddFinishedAndPaidToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :finished, :boolean, :default => false
  end
end
