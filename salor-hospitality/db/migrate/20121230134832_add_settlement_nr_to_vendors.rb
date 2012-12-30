class AddSettlementNrToVendors < ActiveRecord::Migration
  def up
    add_column :vendors, :largest_settlement_number, :integer, :default => 0
    change_column :vendors, :unused_order_numbers, :string, :default => "--- []\n", :limit => 1000
    add_column :vendors, :unused_settlement_numbers, :string, :default => "--- []\n", :limit => 1000
    add_column :vendors, :use_settlement_numbers, :boolean, :default => true
    add_column :settlements, :nr, :integer
  end

  def down
    remove_column :vendors, :largest_settlement_number
    remove_column :vendors, :unused_settlement_numbers
    remove_column :vendors, :use_settlement_numbers
    remove_column :settlements, :nr
  end
end
