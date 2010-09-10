class RemoveCostCenterIdFromItem < ActiveRecord::Migration
  def self.up
    remove_column :items, :cost_center_id
  end

  def self.down
    add_column :items, :cost_center_id, :integer
  end
end
