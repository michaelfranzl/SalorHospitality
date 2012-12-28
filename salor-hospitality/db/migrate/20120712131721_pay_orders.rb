class PayOrders < ActiveRecord::Migration
  def up
    Order.connection.execute('UPDATE orders SET paid = finished')
#     Order.all.each do |o|
#       puts "Setting paid flag for order #{o.id}"
#       o.update_attribute :paid, o.finished
#     end
  end

  def down
  end
end
