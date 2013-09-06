class AddDefaultVendorIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_vendor_id, :integer
  end
end
