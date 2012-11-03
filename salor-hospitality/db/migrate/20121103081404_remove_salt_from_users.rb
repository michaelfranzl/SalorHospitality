class RemoveSaltFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :salt
  end

  def down
    add_column :users, :salt, :string
  end
end
