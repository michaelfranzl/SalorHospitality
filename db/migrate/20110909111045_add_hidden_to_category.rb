class AddHiddenToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :hidden, :boolean
  end

  def self.down
    remove_column :categories, :hidden
  end
end
