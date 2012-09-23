class SetLimitations < ActiveRecord::Migration
  def up
    Vendor.update_all :max_tables => 10, :max_rooms => 5, :max_articles => 50, :max_options => 5, :max_users => 3, :max_categories => 6
    change_column :vendors, :max_tables, :integer, :default => 10
    change_column :vendors, :max_rooms, :integer, :default => 5
    change_column :vendors, :max_articles, :integer, :default => 50
    change_column :vendors, :max_options, :integer, :default => 5
    change_column :vendors, :max_users, :integer, :default => 3
    change_column :vendors, :max_categories, :integer, :default => 6
  end

  def down
  end
end
