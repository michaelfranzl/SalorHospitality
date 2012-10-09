class AddFinishedAtToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :finished_at, :datetime
    add_column :bookings, :finished_at, :datetime
    Order.connection.execute("UPDATE orders SET finished_at = created_at WHERE finished = 1")
    Booking.connection.execute("UPDATE bookings SET finished_at = created_at WHERE finished = 1")
  end
  def down
    remove_column :orders, :finished_at
    remove_column :bookings, :finished_at
  end
end
