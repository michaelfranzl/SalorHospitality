class AddQuantityIdToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :quantity_id, :integer
  end

  def self.down
    remove_column :articles, :quantity_id
  end
end
