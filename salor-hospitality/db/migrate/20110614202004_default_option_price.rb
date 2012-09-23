class DefaultOptionPrice < ActiveRecord::Migration
  def self.up
    change_column :options, :price, :float, :default => 0
  end

  def self.down
    change_column :options, :price, :float
  end
end
