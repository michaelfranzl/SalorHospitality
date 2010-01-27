class AddCostCenterToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :cost_center_id, :integer
  end

  def self.down
    remove_column :items, :cost_center_id
  end
end
