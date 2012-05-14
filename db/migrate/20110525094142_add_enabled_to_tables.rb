class AddEnabledToTables < ActiveRecord::Migration
  def self.up
    add_column :tables, :enabled, :boolean, :default => true
    add_column :tables, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :tables, :enabled
    remove_column :tables, :hidden
  end
end
