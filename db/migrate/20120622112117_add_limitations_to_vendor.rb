class AddLimitationsToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :max_tables, :integer
    add_column :vendors, :max_rooms, :integer
    add_column :vendors, :max_articles, :integer
    add_column :vendors, :max_options, :integer
    add_column :vendors, :max_users, :integer
    add_column :vendors, :max_categories, :integer
  end
end
