class ChangeTimeout < ActiveRecord::Migration
  def up
    remove_column :vendors, :timeout
    add_column :users, :screenlock_timeout, :integer, :default => -1
    remove_column :vendors, :automatic_printing
    add_column :users, :automatic_printing, :boolean
  end
  def down
    add_column :vendors, :timeout, :integer, :default => -1
    remove_column :users, :screenlock_timeout
    add_column :vendors, :automatic_printing, :boolean
    remove_column :users, :automatic_printing
  end
end
