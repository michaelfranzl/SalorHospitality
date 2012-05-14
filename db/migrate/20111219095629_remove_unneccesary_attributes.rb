class RemoveUnneccesaryAttributes < ActiveRecord::Migration
  def up
    remove_column :users, :vendor_id
    remove_column :users, :is_owner
    remove_column :users, :owner_id
    remove_column :vendors, :user_id
    remove_column :articles, :blackboard
    remove_column :articles, :format_division
    remove_column :articles, :format_name
  end

  def down
    add_column :users, :vendor_id, :integer
    add_column :users, :is_owner, :boolean
    add_column :users, :owner_id, :integer
    add_column :vendors, :user_id, :integer
    add_column :articles, :blackboard, :boolean
    add_column :articles, :format_division, :string
    add_column :articles, :format_name, :string
  end
end
