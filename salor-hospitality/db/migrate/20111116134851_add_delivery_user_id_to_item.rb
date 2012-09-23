class AddDeliveryUserIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :delivery_user_id, :integer
  end

  def self.down
    remove_column :items, :delivery_user_id
  end
end
