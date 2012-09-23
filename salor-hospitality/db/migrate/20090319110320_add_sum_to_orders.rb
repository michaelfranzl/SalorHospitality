class AddSumToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :sum, :float
  end

  def self.down
    remove_column :orders, :sum
  end
end
