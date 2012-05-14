class AddMaxCountToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :max_count, :integer, :default => 0
  end

  def self.down
    remove_column :items, :max_count
  end
end
