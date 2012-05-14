class AddHiddenToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :categories, :hidden
  end
end
