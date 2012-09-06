class AddFinishedAtToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :finished_at, :datetime
    add_column :bookings, :finished_at, :datetime
  end
  def down
    remove_column :orders, :finished_at
    remove_column :bookings, :finished_at
  end
end
