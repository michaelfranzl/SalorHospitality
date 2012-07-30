class AddFinishedAtToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :finished_at, :datetime
    add_column :bookings, :finished_at, :datetime
    Order.all.each do |o|
      puts "Updating finished_at for order #{ o.id }"
      o.update_attribute :finished_at, o.created_at
    end
  end
  def down
    remove_column :orders, :finished_at
    remove_column :bookings, :finished_at
  end
end
