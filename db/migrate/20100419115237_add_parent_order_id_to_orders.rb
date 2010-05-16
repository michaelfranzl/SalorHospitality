class AddParentOrderIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :parent_order_id, :integer
  end

  def self.down
    remove_column :orders, :parent_order_id
  end
end
