class AddStornoToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :storno_status, :integer, :default => 0
  end

  def self.down
    remove_column :items, :storno_status
  end
end
