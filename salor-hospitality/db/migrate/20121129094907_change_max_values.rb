class ChangeMaxValues < ActiveRecord::Migration
  def up
    change_column :vendors, :max_tables, :integer, :default => nil
    change_column :vendors, :max_rooms, :integer, :default => nil
    change_column :vendors, :max_articles, :integer, :default => nil
    change_column :vendors, :max_options, :integer, :default => nil
    change_column :vendors, :max_users, :integer, :default => nil
    change_column :vendors, :max_categories, :integer, :default => nil
    Vendor.update_all :max_tables => nil, :max_rooms => nil, :max_articles => nil, :max_users => nil, :max_categories => nil
  end

  def down
  end
end
