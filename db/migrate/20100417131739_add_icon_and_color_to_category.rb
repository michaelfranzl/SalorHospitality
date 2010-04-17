class AddIconAndColorToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :icon, :string
    add_column :categories, :color, :string
  end

  def self.down
    remove_column :categories, :icon, :string
    remove_column :categories, :color, :string
  end
end
