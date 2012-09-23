class AddStornoSumToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :storno_sum, :float, :default => 0
  end

  def self.down
    remove_column :orders, :storno_sum
  end
end
