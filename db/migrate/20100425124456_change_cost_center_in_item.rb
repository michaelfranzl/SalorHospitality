class ChangeCostCenterInItem < ActiveRecord::Migration
  def self.up
    change_column :items, :cost_center_id, :integer, :default => 1
  end

  def self.down
    change_column :items, :cost_center_id, :integer
  end
end
