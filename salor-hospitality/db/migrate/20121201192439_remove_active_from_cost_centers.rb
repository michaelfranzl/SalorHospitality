class RemoveActiveFromCostCenters < ActiveRecord::Migration
  def up
    remove_column :cost_centers, :active
  end

  def down
    add_column :cost_centers, :active, :boolean, :default => true
  end
end
