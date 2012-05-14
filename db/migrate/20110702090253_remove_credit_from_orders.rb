class RemoveCreditFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :credit
  end

  def self.down
    add_column :orders, :credit, :integer
  end
end
