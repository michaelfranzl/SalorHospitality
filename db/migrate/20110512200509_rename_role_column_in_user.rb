class RenameRoleColumnInUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :role, :role_id
  end

  def self.down
    rename_column :users, :role_id, :role
  end
end
