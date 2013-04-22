class AddAdvertisingToVendors < ActiveRecord::Migration
  def change
    add_column :users, :advertising_url, :string
    add_column :users, :advertising_timeout, :integer, :default => -1
  end
end
