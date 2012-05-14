class RemoveFromItems2 < ActiveRecord::Migration
  def change
    remove_column :items, :partial_order
    remove_column :items, :storno_status
    remove_column :items, :storno_item_id
  end
end
