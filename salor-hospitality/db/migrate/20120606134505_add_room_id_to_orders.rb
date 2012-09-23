class AddRoomIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :room_id, :integer
  end
end
