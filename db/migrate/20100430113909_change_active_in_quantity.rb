class ChangeActiveInQuantity < ActiveRecord::Migration
  def self.up
    change_column :quantities, :active, :boolean, :default => true
  end

  def self.down
    change_column :quantities, :active, :boolean
  end
end
