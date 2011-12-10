class AddHiddenToCostCenter < ActiveRecord::Migration
  def self.up
    add_column :cost_centers, :hidden, :boolean
  end

  def self.down
    remove_column :cost_centers, :hidden
  end
end
