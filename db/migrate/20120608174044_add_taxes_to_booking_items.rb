class AddTaxesToBookingItems < ActiveRecord::Migration
  def change
    add_column :booking_items, :taxes, :string, :default => "--- {}\n"
    add_column :bookings, :taxes, :string, :default => "--- {}\n"
  end
end
