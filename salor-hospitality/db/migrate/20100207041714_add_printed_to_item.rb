class AddPrintedToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :printed, :boolean, :default => false
  end

  def self.down
    remove_column :items, :printed
  end
end
