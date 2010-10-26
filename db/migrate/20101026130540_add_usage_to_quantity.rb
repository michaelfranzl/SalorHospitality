class AddUsageToQuantity < ActiveRecord::Migration
  def self.up
    add_column :quantities, :usage, :integer, :default => 0
  end

  def self.down
    remove_column :quantities, :usage
  end
end
