class RemoveUserIdFromTables < ActiveRecord::Migration
  def up
    remove_column :tables, :user_id
  end

  def down
    remove_column :tables, :user_id, :integer
  end
end
