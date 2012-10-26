class RemovePrintPendingFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :print_pending
    remove_column :vendors, :print_data_available
  end

  def down
    add_column :orders, :print_pending, :boolean
    remove_column :vendors, :print_data_available, :boolean
  end
end
