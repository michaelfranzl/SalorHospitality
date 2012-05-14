class ChangeUonVendors < ActiveRecord::Migration
  def up
    change_column :vendors, :unused_order_numbers, :string, :default => "--- []\n", :limit => 10000
  end

  def down
  end
end
