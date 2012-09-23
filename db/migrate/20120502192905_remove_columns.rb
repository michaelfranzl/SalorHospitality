class RemoveColumns < ActiveRecord::Migration
  def change
    remove_column :tables, :abbreviation
    remove_column :tables, :description
    change_column :cost_centers, :active, :boolean, :default => true
    add_column :customers, :hidden, :boolean
    add_column :discounts, :hidden, :boolean
    add_column :discounts, :active, :boolean, :default => true
    add_column :groups, :active, :boolean, :default => true
    add_column :groups, :hidden, :boolean
    add_column :ingredients, :hidden, :boolean
    drop_table :logins
    add_column :options, :active, :boolean, :default => true
    add_column :roles, :active, :boolean, :default => true
    add_column :roles, :hidden, :boolean
    add_column :tables, :active, :boolean, :default => true
    add_column :vendors, :active, :boolean, :default => true
    add_column :vendors, :hidden, :boolean
  end
end
