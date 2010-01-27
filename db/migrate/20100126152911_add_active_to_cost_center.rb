class AddActiveToCostCenter < ActiveRecord::Migration
  def self.up
    add_column :cost_centers, :active, :boolean
  end

  def self.down
    remove_column :cost_centers, :active
  end
end
