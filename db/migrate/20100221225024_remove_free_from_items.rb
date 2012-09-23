class RemoveFreeFromItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :free
  end

  def self.down
    add_column :items, :free, :boolean
  end
end
