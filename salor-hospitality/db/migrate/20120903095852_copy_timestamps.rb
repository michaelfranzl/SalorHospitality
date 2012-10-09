class CopyTimestamps < ActiveRecord::Migration
  def up
    Order.where(:paid => nil).update_all :paid => false
    Order.where(:finished => true).update_all :paid => true

    Order.connection.execute("UPDATE orders SET paid_at = finished_at WHERE finished = 1")
    Booking.connection.execute("UPDATE bookings SET paid_at = finished_at")
  end

  def down
  end
end
