class ChangeTaxSerialization < ActiveRecord::Migration
  def up
    change_column :booking_items, :taxes, :string, :limit => 10000
    change_column :bookings, :taxes, :string, :limit => 10000
    change_column :items, :taxes, :string, :limit => 10000
    change_column :orders, :taxes, :string, :limit => 10000
  end

  def down
  end
end
