class AddSortToArticlesAndQuantities < ActiveRecord::Migration
  def self.up
    add_column :articles, :sort, :integer
    add_column :quantities, :sort, :integer
  end

  def self.down
    remove_column :articles, :sort
    remove_column :quantities, :sort
  end
end
