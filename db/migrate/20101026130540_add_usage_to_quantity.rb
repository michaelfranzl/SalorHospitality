class AddUsageToQuantity < ActiveRecord::Migration
  def self.up
    add_column :quantities, :usage, :string
  end

  def self.down
    remove_column :quantities, :usage
  end
end
