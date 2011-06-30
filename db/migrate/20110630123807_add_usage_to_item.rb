class AddUsageToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :usage, :integer
  end

  def self.down
    remove_column :items, :usage
  end
end
