class AddCostCenterIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :cost_center_id, :integer
  end

  def self.down
    remove_column :orders, :cost_center_id
  end
end
