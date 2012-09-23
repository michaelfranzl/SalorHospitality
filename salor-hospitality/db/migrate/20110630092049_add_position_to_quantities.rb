class AddPositionToQuantities < ActiveRecord::Migration
  def self.up
    add_column :quantities, :position, :integer
  end

  def self.down
    remove_column :quantities, :position
  end
end
