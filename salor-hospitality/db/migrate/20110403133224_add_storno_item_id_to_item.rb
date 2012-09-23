class AddStornoItemIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :storno_item_id, :integer
  end

  def self.down
    remove_column :items, :storno_item_id
  end
end
