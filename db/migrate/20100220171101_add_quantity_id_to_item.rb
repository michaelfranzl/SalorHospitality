class AddQuantityIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :quantity_id, :integer
  end

  def self.down
    remove_column :items, :quantity_id
  end
end	
