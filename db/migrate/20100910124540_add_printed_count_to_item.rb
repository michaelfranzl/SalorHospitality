class AddPrintedCountToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :printed_count, :integer, :default => 0
    remove_column :items, :printed
  end

  def self.down
    remove_column :items, :printed_count
    add_column :items, :printed, :boolean, :default => false
  end
end
