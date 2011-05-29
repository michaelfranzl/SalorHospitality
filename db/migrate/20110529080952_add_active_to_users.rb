class AddActiveToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default => true
    add_column :users, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :users, :active
    remove_column :users, :hidden
  end
end
