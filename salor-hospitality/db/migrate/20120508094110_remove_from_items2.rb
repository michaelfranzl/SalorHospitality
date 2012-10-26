class RemoveFromItems2 < ActiveRecord::Migration
  def up
    Item.where(:storno_status => 2).delete_all
    Item.where(:storno_status => 3).update_all :refunded => true
    remove_column :items, :partial_order
    remove_column :items, :storno_status
    remove_column :items, :storno_item_id
  end
  def down
    add_column :items, :partial_order, :integer
    add_column :items, :storno_status, :integer, :default => 0
    add_column :items, :storno_item_id, :integer
  end
end
