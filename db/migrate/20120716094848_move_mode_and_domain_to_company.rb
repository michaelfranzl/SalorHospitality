class MoveModeAndDomainToCompany < ActiveRecord::Migration
  def up
    remove_column :vendors, :mode
    remove_column :vendors, :subdomain
    add_column :companies, :mode, :string, :default => 'local'
    add_column :companies, :subdomain, :string
    add_column :companies, :update_tables, :integer, :default => 20
    add_column :companies, :update_item_lists, :integer, :default => 61
    add_column :companies, :update_resources, :integer, :default => 182
  end
  def down
    add_column :vendors, :mode, :string
    add_column :vendors, :subdomain, :string
    remove_column :companies, :mode
    remove_column :companies, :subdomain
    remove_column :companies, :update_tables
    remove_column :companies, :update_item_lists
    remove_column :companies, :update_resources
  end
end