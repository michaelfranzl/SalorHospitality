class AddPriorityToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :priority, :integer
  end

  def self.down
    remove_column :items, :priority
  end
end
