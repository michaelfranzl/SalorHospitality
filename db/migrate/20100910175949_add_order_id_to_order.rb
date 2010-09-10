class AddOrderIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :order_id, :integer
  end

  def self.down
    remove_column :orders, :order_id
  end
end
