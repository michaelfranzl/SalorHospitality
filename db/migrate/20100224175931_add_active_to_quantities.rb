class AddActiveToQuantities < ActiveRecord::Migration
  def self.up
    add_column :quantities, :active, :boolean
  end

  def self.down
    remove_column :quantities, :active
  end
end
