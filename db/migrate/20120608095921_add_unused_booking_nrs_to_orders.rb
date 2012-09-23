class AddUnusedBookingNrsToOrders < ActiveRecord::Migration
  def change
    add_column :vendors, :unused_booking_numbers, :string, :default => "--- []\n", :limit => 10000
    add_column :vendors, :largest_booking_number, :integer, :default => 0
    add_column :vendors, :use_booking_numbers, :boolean, :default => true
    add_column :bookings, :nr, :integer
    add_column :bookings, :change_given, :float
  end
end
