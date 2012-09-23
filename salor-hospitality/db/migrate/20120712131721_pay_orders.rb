class PayOrders < ActiveRecord::Migration
  def up
    Order.all.each do |o|
      puts "Setting paid flag for order #{o.id}"
      o.update_attribute :paid, o.finished
    end
  end

  def down
  end
end
