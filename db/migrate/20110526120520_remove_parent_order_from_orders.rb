class RemoveParentOrderFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :parent_order_id
  end

  def self.down
    add_column :orders, :parent_order_id, :integer
  end
end
