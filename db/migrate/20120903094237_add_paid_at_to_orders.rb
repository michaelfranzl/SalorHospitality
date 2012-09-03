class AddPaidAtToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :paid_at, :datetime
    add_column :bookings, :paid_at, :datetime
    change_column :orders, :paid, :boolean, :default => false
  end
  def down
    remove_column :orders, :paid_at
    remove_column :bookings, :paid_at
    change_column :orders, :paid, :boolean
  end
end
