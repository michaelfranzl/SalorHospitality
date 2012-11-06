class AddRemoteOrdersToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :remote_orders, :boolean
  end
end
