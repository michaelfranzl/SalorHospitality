class AddCustomerIdIndexToOrders < ActiveRecord::Migration
  def self.up
    add_index :orders, :customer_id
  end

  def self.down
    remove_index :orders, :customer_id
  end
end
