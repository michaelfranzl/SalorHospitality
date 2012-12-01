class MoveTimersFromCompanyToVendor < ActiveRecord::Migration
  def up
    remove_column :companies, :update_tables
    remove_column :companies, :update_item_lists
    remove_column :companies, :update_resources
    add_column :vendors, :update_tables_interval, :integer, :default => 19
    add_column :vendors, :update_item_lists_interval, :integer, :default => 31
    add_column :vendors, :update_resources_interval, :integer, :default => 127
  end

  def down
    remove_column :vendors, :update_tables_interval
    remove_column :vendors, :update_item_lists_interval
    remove_column :vendors, :update_resources_interval
    add_column :companies, :update_tables, :integer
    add_column :companies, :update_item_lists, :integer
    add_column :companies, :update_resources, :integer
  end
end
