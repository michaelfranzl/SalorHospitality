class AddPrivateUserIdToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :active_user_id, :integer
  end

  def self.down
    remove_column :tables, :active_user_id
  end
end
