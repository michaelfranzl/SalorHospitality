class AddUserIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :user_id, :integer
    add_column :items, :preparation_user_id, :integer
  end

  def self.down
    remove_column :items, :user_id
    remove_column :items, :preparation_user_id
  end
end
