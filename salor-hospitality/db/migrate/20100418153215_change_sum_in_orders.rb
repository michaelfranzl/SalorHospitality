class ChangeSumInOrders < ActiveRecord::Migration
  def self.up
    change_column :orders, :sum, :float, :default => 0
  end

  def self.down
    change_column :orders, :sum, :float, :default => 0
  end
end
