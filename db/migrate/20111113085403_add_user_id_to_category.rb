class AddUserIdToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :user_id, :integer
  end

  def self.down
    remove_column :categories, :user_id
  end
end
