class ChangeNames < ActiveRecord::Migration
  def self.up
    rename_column :categories, :user_id, :preparation_user_id
  end

  def self.down
    rename_column :categories, :preparation_user_id, :user_id
  end
end
