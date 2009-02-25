class AddPartialOrderToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :partial_order, :boolean
  end

  def self.down
    remove_column :items, :partial_order
  end
end
