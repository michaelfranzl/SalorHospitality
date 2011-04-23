class AddPrintPendingToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :print_pending, :boolean
  end

  def self.down
    remove_column :orders, :print_pending
  end
end
