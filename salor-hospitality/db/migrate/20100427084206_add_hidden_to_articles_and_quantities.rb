class AddHiddenToArticlesAndQuantities < ActiveRecord::Migration
  def self.up
    add_column :articles, :hidden, :boolean, :default => false
    add_column :quantities, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :articles, :hidden
    remove_column :quantities, :hidden
  end
end
