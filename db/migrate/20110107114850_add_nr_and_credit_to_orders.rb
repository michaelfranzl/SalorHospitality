class AddNrAndCreditToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :nr, :integer
    add_column :orders, :credit, :integer, :default => 0
  end

  def self.down
    remove_column :orders, :credit
    remove_column :orders, :nr
  end
end
