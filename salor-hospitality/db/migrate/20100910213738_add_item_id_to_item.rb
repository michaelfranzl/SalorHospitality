class AddItemIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :item_id, :integer
  end

  def self.down
    remove_column :items, :item_id
  end
end
